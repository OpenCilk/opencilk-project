//===- TapirToTarget.cpp - Convert Tapir into parallel-runtime calls ------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This pass converts functions that use Tapir instructions to call out to a
// target parallel runtime system.
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/Tapir/TapirToTarget.h"
#include "llvm/Analysis/AssumptionCache.h"
#include "llvm/Analysis/TapirTaskInfo.h"
#include "llvm/Analysis/TargetLibraryInfo.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/PassManager.h"
#include "llvm/IR/Verifier.h"
#include "llvm/InitializePasses.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Timer.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Transforms/Tapir.h"
#include "llvm/Transforms/Tapir/LoweringUtils.h"
#include "llvm/Transforms/Utils/TapirUtils.h"

#define DEBUG_TYPE "tapir2target"

using namespace llvm;

cl::opt<bool> DebugABICalls(
    "debug-abi-calls", cl::init(false), cl::Hidden,
    cl::desc("Insert ABI calls simply, to debug generated IR"));

cl::opt<bool> UseExternalABIFunctions(
    "use-external-abi-functions", cl::init(false), cl::Hidden,
    cl::desc("Use ABI functions defined externally, rather than "
             "compiler-generated versions"));

static const char TimerGroupName[] = DEBUG_TYPE;
static const char TimerGroupDescription[] = "Tapir to Target";

class TapirToTargetImpl {
public:
  TapirToTargetImpl(Module &M, function_ref<DominatorTree &(Function &)> GetDT,
                    function_ref<TaskInfo &(Function &)> GetTI,
                    function_ref<AssumptionCache &(Function &)> GetAC,
                    function_ref<TargetLibraryInfo &(Function &)> GetTLI)
      : M(M), GetDT(GetDT), GetTI(GetTI), GetAC(GetAC), GetTLI(GetTLI) {}
  ~TapirToTargetImpl() {
    if (Target)
      delete Target;
  }

  bool run();

private:
  bool unifyReturns(Function &F);
  void processFunction(Function &F, SmallVectorImpl<Function *> &NewHelpers);
  TFOutlineMapTy outlineAllTasks(Function &F,
                                 SmallVectorImpl<Spindle *> &AllTaskFrames,
                                 DominatorTree &DT, AssumptionCache &AC,
                                 TaskInfo &TI);
  bool processSimpleABI(Function &F);
  bool processRootTask(Function &F, TFOutlineMapTy &TFToOutline,
                       DominatorTree &DT, AssumptionCache &AC, TaskInfo &TI);
  bool processSpawnerTaskFrame(Spindle *TF, TFOutlineMapTy &TFToOutline,
                               DominatorTree &DT, AssumptionCache &AC,
                               TaskInfo &TI);
  bool processOutlinedTask(Task *T, TFOutlineMapTy &TFToOutline,
                           DominatorTree &DT, AssumptionCache &AC,
                           TaskInfo &TI);

private:
  TapirTarget *Target = nullptr;

  Module &M;

  function_ref<DominatorTree &(Function &)> GetDT;
  function_ref<TaskInfo &(Function &)> GetTI;
  function_ref<AssumptionCache &(Function &)> GetAC;
  function_ref<TargetLibraryInfo &(Function &)> GetTLI;
};

bool TapirToTargetImpl::unifyReturns(Function &F) {
  NamedRegionTimer NRT("unifyReturns", "Unify returns", TimerGroupName,
                       TimerGroupDescription, TimePassesIsEnabled);
  SmallVector<BasicBlock *, 4> ReturningBlocks;
  for (BasicBlock &BB : F)
    if (isa<ReturnInst>(BB.getTerminator()))
      ReturningBlocks.push_back(&BB);

  // If this function already has no returns or a single return, then terminate
  // early.
  if (ReturningBlocks.size() <= 1)
    return false;

  BasicBlock *NewRetBlock = BasicBlock::Create(F.getContext(),
                                               "UnifiedReturnBlock", &F);
  PHINode *PN = nullptr;
  if (F.getReturnType()->isVoidTy()) {
    ReturnInst::Create(F.getContext(), nullptr, NewRetBlock);
  } else {
    // If the function doesn't return void... add a PHI node to the block...
    PN = PHINode::Create(F.getReturnType(), ReturningBlocks.size(),
                         "UnifiedRetVal");
    NewRetBlock->getInstList().push_back(PN);
    ReturnInst::Create(F.getContext(), PN, NewRetBlock);
  }

  // Loop over all of the blocks, replacing the return instruction with an
  // unconditional branch.
  //
  for (BasicBlock *BB : ReturningBlocks) {
    // Add an incoming element to the PHI node for every return instruction that
    // is merging into this new block...
    if (PN)
      PN->addIncoming(BB->getTerminator()->getOperand(0), BB);

    BB->getInstList().pop_back();  // Remove the return insn
    BranchInst::Create(NewRetBlock, BB);
  }
  return true;
}

/// Outline all tasks in this function in post order.
TFOutlineMapTy
TapirToTargetImpl::outlineAllTasks(Function &F,
                                   SmallVectorImpl<Spindle *> &AllTaskFrames,
                                   DominatorTree &DT, AssumptionCache &AC,
                                   TaskInfo &TI) {
  NamedRegionTimer NRT("outlineAllTasks", "Outline all tasks", TimerGroupName,
                       TimerGroupDescription, TimePassesIsEnabled);
  TFOutlineMapTy TFToOutline;

  // Determine the inputs for all tasks.
  TFValueSetMap TFInputs, TFOutputs;
  findAllTaskFrameInputs(TFInputs, TFOutputs, AllTaskFrames, F, DT, TI);

  DenseMap<Spindle *, SmallVector<Value *, 8>> HelperInputs;

  for (Spindle *TF : AllTaskFrames) {
    // At this point, all subtaskframess of TF must have been processed.
    // Replace the tasks with calls to their outlined helper functions.
    for (Spindle *SubTF : TF->subtaskframes())
      TFToOutline[SubTF].replaceReplCall(
          replaceTaskFrameWithCallToOutline(SubTF, TFToOutline[SubTF],
                                            HelperInputs[SubTF]));

    // TODO: Add support for outlining taskframes with no associated task.  Such
    // a facility would allow the frontend to create nested sync regions that
    // are properly outlined.

    Task *T = TF->getTaskFromTaskFrame();
    if (!T) {
      ValueToValueMapTy VMap;
      ValueToValueMapTy InputMap;
      TFToOutline[TF] = outlineTaskFrame(TF, TFInputs[TF], HelperInputs[TF],
                                         &Target->getDestinationModule(), VMap,
                                         Target->getArgStructMode(),
                                         Target->getReturnType(), InputMap, &AC,
                                         &DT);
      // If the taskframe TF does not catch an exception from the taskframe,
      // then the outlined function cannot throw.
      if (F.doesNotThrow() && !getTaskFrameResume(TF->getTaskFrameCreate()))
        TFToOutline[TF].Outline->setDoesNotThrow();
      Target->addHelperAttributes(*TFToOutline[TF].Outline);

      // Update subtaskframe outline info to reflect the fact that their parent
      // taskframe was outlined.
      for (Spindle *SubTF : TF->subtaskframes())
        TFToOutline[SubTF].remapOutlineInfo(VMap, InputMap);

      continue;
    }

    // Outline the task, if necessary, and add the outlined function to the
    // mapping.

    ValueToValueMapTy VMap;
    ValueToValueMapTy InputMap;
    TFToOutline[TF] = outlineTask(T, TFInputs[TF], HelperInputs[TF],
                                  &Target->getDestinationModule(), VMap,
                                  Target->getArgStructMode(),
                                  Target->getReturnType(), InputMap, &AC, &DT);
    // If the detach for task T does not catch an exception from the task, then
    // the outlined function cannot throw.
    if (F.doesNotThrow() && !T->getDetach()->hasUnwindDest())
      TFToOutline[TF].Outline->setDoesNotThrow();
    Target->addHelperAttributes(*TFToOutline[TF].Outline);

    // Update subtask outline info to reflect the fact that their spawner was
    // outlined.
    for (Spindle *SubTF : TF->subtaskframes())
      TFToOutline[SubTF].remapOutlineInfo(VMap, InputMap);
  }

  // Insert calls to outlined helpers for taskframe roots.
  for (Spindle *TF : TI.getRootTask()->taskframe_roots())
    TFToOutline[TF].replaceReplCall(
        replaceTaskFrameWithCallToOutline(TF, TFToOutline[TF],
                                          HelperInputs[TF]));

  return TFToOutline;
}

/// Process the Tapir instructions in function \p F directly.
bool TapirToTargetImpl::processSimpleABI(Function &F) {
  NamedRegionTimer NRT("processSimpleABI", "Process simple ABI", TimerGroupName,
                       TimerGroupDescription, TimePassesIsEnabled);

  // Get the simple Tapir instructions to process, including syncs and
  // loop-grainsize calls.
  SmallVector<SyncInst *, 8> Syncs;
  SmallVector<CallInst *, 8> GrainsizeCalls;
  SmallVector<CallInst *, 8> TaskFrameAddrCalls;
  for (BasicBlock &BB : F) {
    for (Instruction &I : BB) {
      // Record calls to get Tapir-loop grainsizes.
      if (IntrinsicInst *II = dyn_cast<IntrinsicInst>(&I))
        if (Intrinsic::tapir_loop_grainsize == II->getIntrinsicID())
          GrainsizeCalls.push_back(II);

      // Record calls to task_frameaddr intrinsics.
      if (IntrinsicInst *II = dyn_cast<IntrinsicInst>(&I))
        if (Intrinsic::task_frameaddress == II->getIntrinsicID())
          TaskFrameAddrCalls.push_back(II);

      // Record sync instructions in this function.
      if (SyncInst *SI = dyn_cast<SyncInst>(&I))
        Syncs.push_back(SI);
    }
  }

  // Lower simple Tapir instructions in this function.  Collect the set of
  // helper functions generated by this process.
  bool Changed = false;

  // Lower calls to get Tapir-loop grainsizes.
  while (!GrainsizeCalls.empty()) {
    CallInst *GrainsizeCall = GrainsizeCalls.pop_back_val();
    LLVM_DEBUG(dbgs() << "Lowering grainsize call " << *GrainsizeCall << "\n");
    Target->lowerGrainsizeCall(GrainsizeCall);
    Changed = true;
  }

  // Lower calls to task_frameaddr intrinsics.
  while (!TaskFrameAddrCalls.empty()) {
    CallInst *TaskFrameAddrCall = TaskFrameAddrCalls.pop_back_val();
    LLVM_DEBUG(dbgs() << "Lowering task_frameaddr call " << *TaskFrameAddrCall
               << "\n");
    Target->lowerTaskFrameAddrCall(TaskFrameAddrCall);
    Changed = true;
  }

  // Process the set of syncs.
  while (!Syncs.empty()) {
    SyncInst *SI = Syncs.pop_back_val();
    Target->lowerSync(*SI);
    Changed = true;
  }

  return Changed;
}

bool TapirToTargetImpl::processRootTask(
    Function &F, TFOutlineMapTy &TFToOutline, DominatorTree &DT,
    AssumptionCache &AC, TaskInfo &TI) {
  NamedRegionTimer NRT("processRootTask", "Process root task",
                       TimerGroupName, TimerGroupDescription,
                       TimePassesIsEnabled);
  bool Changed = false;
  // Check if the root task performs a spawn
  bool PerformsSpawn = false;
  for (Spindle *TF : TI.getRootTask()->taskframe_roots()) {
    if (TF->getTaskFromTaskFrame()) {
      PerformsSpawn = true;
      break;
    }
  }
  if (PerformsSpawn) {
    Changed = true;
    // Process root-task function F as a spawner.
    Target->preProcessRootSpawner(F);

    // Process each call to a subtask.
    for (Spindle *TF : TI.getRootTask()->taskframe_roots())
      if (TF->getTaskFromTaskFrame())
        Target->processSubTaskCall(TFToOutline[TF], DT);

    Target->postProcessRootSpawner(F);
  }
  // Process the Tapir instructions in F directly.
  Changed |= processSimpleABI(F);
  return Changed;
}

bool TapirToTargetImpl::processSpawnerTaskFrame(
    Spindle *TF, TFOutlineMapTy &TFToOutline, DominatorTree &DT,
    AssumptionCache &AC, TaskInfo &TI) {
  NamedRegionTimer NRT("processSpawnerTaskFrame", "Process spawner taskframe",
                       TimerGroupName, TimerGroupDescription,
                       TimePassesIsEnabled);
  Function &F = *TFToOutline[TF].Outline;

  // Process function F as a spawner.
  Target->preProcessRootSpawner(F);

  // Process each call to a subtask.
  for (Spindle *SubTF : TF->subtaskframes())
    if (SubTF->getTaskFromTaskFrame())
      Target->processSubTaskCall(TFToOutline[SubTF], DT);

  Target->postProcessRootSpawner(F);

  // Process the Tapir instructions in F directly.
  processSimpleABI(F);
  return true;
}

bool TapirToTargetImpl::processOutlinedTask(
    Task *T, TFOutlineMapTy &TFToOutline, DominatorTree &DT,
    AssumptionCache &AC, TaskInfo &TI) {
  NamedRegionTimer NRT("processOutlinedTask", "Process outlined task",
                       TimerGroupName, TimerGroupDescription,
                       TimePassesIsEnabled);
  Spindle *TF = getTaskFrameForTask(T);
  Function &F = *TFToOutline[TF].Outline;

  Instruction *DetachPt = TFToOutline[TF].DetachPt;
  Instruction *TaskFrameCreate = TFToOutline[TF].TaskFrameCreate;

  Target->preProcessOutlinedTask(F, DetachPt, TaskFrameCreate,
                                 !T->isSerial());
  // Process each call to a subtask.
  for (Spindle *SubTF : TF->subtaskframes())
    if (SubTF->getTaskFromTaskFrame())
      Target->processSubTaskCall(TFToOutline[SubTF], DT);

  Target->postProcessOutlinedTask(F, DetachPt, TaskFrameCreate,
                                  !T->isSerial());

  // Process the Tapir instructions in F directly.
  processSimpleABI(F);
  return true;
}

// Helper method to check if the given taskframe spindle performs any spawns.
static bool isSpawningTaskFrame(const Spindle *TF) {
  for (const Spindle *SubTF : TF->subtaskframes())
    if (SubTF->getTaskFromTaskFrame())
      return true;
  return false;
}

// Helper method to check if the given taskframe corresponds to a spawned task.
static bool isSpawnedTaskFrame(const Spindle *TF) {
  return TF->getTaskFromTaskFrame();
}

void TapirToTargetImpl::processFunction(
    Function &F, SmallVectorImpl<Function *> &NewHelpers) {
  LLVM_DEBUG(dbgs() << "Tapir: Processing function " << F.getName() << "\n");

  // Get the necessary analysis results.
  DominatorTree &DT = GetDT(F);
  TaskInfo &TI = GetTI(F);
  splitTaskFrameCreateBlocks(F, &DT, &TI);
  TI.findTaskFrameTree();
  AssumptionCache &AC = GetAC(F);

  {
  NamedRegionTimer NRT("TargetPreProcess", "Target preprocessing",
                       TimerGroupName, TimerGroupDescription,
                       TimePassesIsEnabled);
  Target->preProcessFunction(F, TI);
  } // end timed region

  // If we don't need to do outlining, then just handle the simple ABI.
  if (!Target->shouldDoOutlining(F)) {
    // Process the Tapir instructions in F directly.
    processSimpleABI(F);
    return;
  }

  // Traverse the tasks in this function in post order.
  SmallVector<Spindle *, 8> AllTaskFrames;

  // Collect all taskframes in the function in postorder.
  for (Spindle *TFRoot : TI.getRootTask()->taskframe_roots())
    for (Spindle *TFSpindle : post_order<TaskFrames<Spindle *>>(TFRoot))
      AllTaskFrames.push_back(TFSpindle);

  // Fixup external uses of values defined in taskframes.
  for (Spindle *TF : AllTaskFrames)
    fixupTaskFrameExternalUses(TF, TI, DT);

  // Outline all tasks in a target-oblivious manner.
  TFOutlineMapTy TFToOutline = outlineAllTasks(F, AllTaskFrames, DT, AC, TI);

  // Perform target-specific processing of this function and all newly created
  // helpers.
  for (Spindle *TF : AllTaskFrames) {
    if (isSpawningTaskFrame(TF) && !isSpawnedTaskFrame(TF))
      processSpawnerTaskFrame(TF, TFToOutline, DT, AC, TI);
    else if (isSpawnedTaskFrame(TF))
      processOutlinedTask(TF->getTaskFromTaskFrame(), TFToOutline, DT, AC, TI);
    else
      processSimpleABI(*TFToOutline[TF].Outline);
    NewHelpers.push_back(TFToOutline[TF].Outline);
  }
  // Process the root task
  processRootTask(F, TFToOutline, DT, AC, TI);

  {
  NamedRegionTimer NRT("TargetPostProcess", "Target postprocessing",
                       TimerGroupName, TimerGroupDescription,
                       TimePassesIsEnabled);
  Target->postProcessFunction(F);
  for (Function *H : NewHelpers)
    Target->postProcessHelper(*H);
  } // end timed region

  LLVM_DEBUG({
    NamedRegionTimer NRT("FunctionVerify",
                         "Post-lowering function verification", TimerGroupName,
                         TimerGroupDescription, TimePassesIsEnabled);
    if (verifyFunction(F, &errs())) {
      LLVM_DEBUG(dbgs() << "Function after lowering:" << F);
      llvm_unreachable("Tapir lowering produced bad IR!");
    }
    for (Function *H : NewHelpers)
      if (verifyFunction(*H, &errs())) {
        LLVM_DEBUG(dbgs() << "Function after lowering:" << *H);
        llvm_unreachable("Tapir lowering produced bad IR!");
      }
  });

  return;
}

bool TapirToTargetImpl::run() {
  // Add functions that detach to the work list.
  SmallVector<Function *, 4> WorkList;
  {
  NamedRegionTimer NRT("shouldProcessFunction", "Find functions to process",
                       TimerGroupName, TimerGroupDescription,
                       TimePassesIsEnabled);
  for (Function &F : M) {
    if (F.empty())
      continue;
    // TODO: Use per-function Tapir targets?
    if (!Target)
      Target = getTapirTargetFromID(M, GetTLI(F).getTapirTarget());
    assert(Target && "Missing Tapir target");
    if (Target->shouldProcessFunction(F))
      WorkList.push_back(&F);
  }
  }

  // Quit early if there are no functions in this module to lower.
  if (WorkList.empty())
    return false;

  // There are functions in this module to lower.  Prepare the module for Tapir
  // lowering.
  Target->prepareModule();

  bool Changed = false;
  while (!WorkList.empty()) {
    // Process the next function.
    Function *F = WorkList.pop_back_val();
    SmallVector<Function *, 4> NewHelpers;

    processFunction(*F, NewHelpers);
    Changed |= !NewHelpers.empty();

    // Check the generated helper functions to see if any need to be processed,
    // that is, to see if any of them themselves detach a subtask.
    {
    NamedRegionTimer NRT("shouldProcessHelper",
                         "Find helper functions to process", TimerGroupName,
                         TimerGroupDescription, TimePassesIsEnabled);
    for (Function *Helper : NewHelpers)
      if (Target->shouldProcessFunction(*Helper))
        WorkList.push_back(Helper);
    }
  }
  return Changed;
}

PreservedAnalyses TapirToTargetPass::run(Module &M, ModuleAnalysisManager &AM) {
  auto &FAM = AM.getResult<FunctionAnalysisManagerModuleProxy>(M).getManager();
  auto GetDT = [&FAM](Function &F) -> DominatorTree & {
    return FAM.getResult<DominatorTreeAnalysis>(F);
  };
  auto GetTI = [&FAM](Function &F) -> TaskInfo & {
    return FAM.getResult<TaskAnalysis>(F);
  };
  auto GetAC = [&FAM](Function &F) -> AssumptionCache & {
    return FAM.getResult<AssumptionAnalysis>(F);
  };
  auto GetTLI = [&FAM](Function &F) -> TargetLibraryInfo & {
    return FAM.getResult<TargetLibraryAnalysis>(F);
  };

  bool Changed = TapirToTargetImpl(M, GetDT, GetTI, GetAC, GetTLI).run();

  if (Changed)
    return PreservedAnalyses::none();
  return PreservedAnalyses::all();
}

namespace {
struct LowerTapirToTarget : public ModulePass {
  static char ID; // Pass identification, replacement for typeid
  explicit LowerTapirToTarget() : ModulePass(ID) {
    initializeLowerTapirToTargetPass(*PassRegistry::getPassRegistry());
  }

  StringRef getPassName() const override { return "Lower Tapir to target"; }

  bool runOnModule(Module &M) override;

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<AssumptionCacheTracker>();
    AU.addRequired<DominatorTreeWrapperPass>();
    AU.addRequired<TargetLibraryInfoWrapperPass>();
    AU.addRequired<TaskInfoWrapperPass>();
  }
};
} // End of anonymous namespace

char LowerTapirToTarget::ID = 0;
INITIALIZE_PASS_BEGIN(LowerTapirToTarget, "tapir2target",
                      "Lower Tapir to Target ABI", false, false)
INITIALIZE_PASS_DEPENDENCY(AssumptionCacheTracker)
INITIALIZE_PASS_DEPENDENCY(DominatorTreeWrapperPass)
INITIALIZE_PASS_DEPENDENCY(TargetLibraryInfoWrapperPass)
INITIALIZE_PASS_DEPENDENCY(TaskInfoWrapperPass)
INITIALIZE_PASS_END(LowerTapirToTarget, "tapir2target",
                    "Lower Tapir to Target ABI", false, false)

bool LowerTapirToTarget::runOnModule(Module &M) {
  if (skipModule(M))
    return false;
  auto GetDT = [this](Function &F) -> DominatorTree & {
    return this->getAnalysis<DominatorTreeWrapperPass>(F).getDomTree();
  };
  auto GetTI = [this](Function &F) -> TaskInfo & {
    return this->getAnalysis<TaskInfoWrapperPass>(F).getTaskInfo();
  };
  AssumptionCacheTracker *ACT = &getAnalysis<AssumptionCacheTracker>();
  auto GetAC = [&ACT](Function &F) -> AssumptionCache & {
    return ACT->getAssumptionCache(F);
  };
  auto GetTLI = [this](Function &F) -> TargetLibraryInfo & {
    return this->getAnalysis<TargetLibraryInfoWrapperPass>().getTLI(F);
  };

  return TapirToTargetImpl(M, GetDT, GetTI, GetAC, GetTLI).run();
}

// createLowerTapirToTargetPass - Provide an entry point to create this pass.
//
namespace llvm {
ModulePass *createLowerTapirToTargetPass() { return new LowerTapirToTarget(); }
} // namespace llvm
