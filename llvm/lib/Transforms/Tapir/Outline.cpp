//===- TapirOutline.cpp - Outlining for Tapir -----------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements helper functions for outlining portions of code
// containing Tapir instructions.
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/Tapir/Outline.h"
#include "llvm/IR/DebugInfo.h"
#include "llvm/IR/DIBuilder.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/Support/Timer.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/Local.h"
#include "llvm/Transforms/Utils/TapirUtils.h"

using namespace llvm;

#define DEBUG_TYPE "outlining"

static const char TimerGroupName[] = DEBUG_TYPE;
static const char TimerGroupDescription[] = "Tapir outlining";

// Materialize any necessary information in DstM when outlining Tapir into DstM.
Value *OutlineMaterializer::materialize(Value *V) {
  if (V == SrcSyncRegion) {
    // Create a new sync region to replace the sync region SrcSyncRegion from
    // the source.

    // Get the destination function
    User *U = *(V->materialized_user_begin());
    Function *DstFunc = cast<Instruction>(U)->getFunction();
    // Add a new syncregion to the entry block of the destination function
    Instruction *NewSyncReg = cast<Instruction>(SrcSyncRegion)->clone();
    BasicBlock *EntryBlock = &DstFunc->getEntryBlock();
    EntryBlock->getInstList().push_back(NewSyncReg);
    // Record the entry block as needing remapping
    BlocksToRemap.insert(EntryBlock);
    return NewSyncReg;
  }

  return nullptr;
}

// Clone Blocks into NewFunc, transforming the old arguments into references to
// VMap values.
//
/// TODO: Fix the std::vector part of the type of this function.
void llvm::CloneIntoFunction(Function *NewFunc, const Function *OldFunc,
                             std::vector<BasicBlock *> Blocks,
                             ValueToValueMapTy &VMap, bool ModuleLevelChanges,
                             SmallVectorImpl<ReturnInst *> &Returns,
                             const StringRef NameSuffix,
                             SmallPtrSetImpl<BasicBlock *> *ReattachBlocks,
                             SmallPtrSetImpl<BasicBlock *> *TaskResumeBlocks,
                             SmallPtrSetImpl<BasicBlock *> *SharedEHEntries,
                             DISubprogram *SP, ClonedCodeInfo *CodeInfo,
                             ValueMapTypeRemapper *TypeMapper,
                             OutlineMaterializer *Materializer) {
  // Get the predecessors of the exit blocks
  SmallPtrSet<const BasicBlock *, 4> EHEntryPreds, ClonedEHEntryPreds;
  if (SharedEHEntries)
    for (BasicBlock *EHEntry : *SharedEHEntries)
      for (BasicBlock *Pred : predecessors(EHEntry))
        EHEntryPreds.insert(Pred);

  // When we remap instructions, we want to avoid duplicating inlined
  // DISubprograms, so record all subprograms we find as we duplicate
  // instructions and then freeze them in the MD map.
  // We also record information about dbg.value and dbg.declare to avoid
  // duplicating the types.
  DebugInfoFinder DIFinder;

  // Loop over all of the basic blocks in the function, cloning them as
  // appropriate.
  {
  NamedRegionTimer NRT("CloneBlocks", "Clone basic blocks",
                       TimerGroupName, TimerGroupDescription,
                       TimePassesIsEnabled);
  for (const BasicBlock *BB : Blocks) {
    // Record all exit block predecessors that are cloned.
    if (EHEntryPreds.count(BB))
      ClonedEHEntryPreds.insert(BB);

    // Create a new basic block and copy instructions into it!
    BasicBlock *CBB = CloneBasicBlock(BB, VMap, NameSuffix, NewFunc, CodeInfo,
                                      SP ? &DIFinder : nullptr);

    // Add basic block mapping.
    VMap[BB] = CBB;

    // It is only legal to clone a function if a block address within that
    // function is never referenced outside of the function.  Given that, we
    // want to map block addresses from the old function to block addresses in
    // the clone. (This is different from the generic ValueMapper
    // implementation, which generates an invalid blockaddress when cloning a
    // function.)
    if (BB->hasAddressTaken()) {
      Constant *OldBBAddr = BlockAddress::get(const_cast<Function *>(OldFunc),
                                              const_cast<BasicBlock *>(BB));
      VMap[OldBBAddr] = BlockAddress::get(NewFunc, CBB);
    }

    // Note return instructions for the caller.
    if (ReturnInst *RI = dyn_cast<ReturnInst>(CBB->getTerminator()))
      Returns.push_back(RI);
  }
  } // end timed region

  // For each exit block, clean up its phi nodes to exclude predecessors that
  // were not cloned.  Also replace detached_rethrow invokes with resumes.
  if (SharedEHEntries) {
    NamedRegionTimer NRT("FixupSharedEH", "Fixup shared EH blocks",
                         TimerGroupName, TimerGroupDescription,
                         TimePassesIsEnabled);
    for (BasicBlock *EHEntry : *SharedEHEntries) {
      if (!VMap[EHEntry])
        continue;

      // Get the predecessors of this exit block that were not cloned.
      SmallVector<BasicBlock *, 4> PredNotCloned;
      for (BasicBlock *Pred : predecessors(EHEntry))
        if (!ClonedEHEntryPreds.count(Pred))
          PredNotCloned.push_back(Pred);

      // Iterate over the phi nodes in the cloned exit block and remove incoming
      // values from predecessors that were not cloned.
      BasicBlock *ClonedEHEntry = cast<BasicBlock>(VMap[EHEntry]);
      BasicBlock::iterator BI = ClonedEHEntry->begin();
      while (PHINode *PN = dyn_cast<PHINode>(BI)) {
        for (BasicBlock *DeadPred : PredNotCloned)
          if (PN->getBasicBlockIndex(DeadPred) > -1)
            PN->removeIncomingValue(DeadPred);
        ++BI;
      }
    }
  }
  if (ReattachBlocks) {
    NamedRegionTimer NRT("FixupReattach", "Fixup reattach blocks",
                         TimerGroupName, TimerGroupDescription,
                         TimePassesIsEnabled);
    for (BasicBlock *ReattachBlk : *ReattachBlocks) {
      BasicBlock *ClonedRB = cast<BasicBlock>(VMap[ReattachBlk]);
      // Don't get the remapped name of this successor yet.  Subsequent
      // remapping will take correct the name.
      BasicBlock *Succ = ClonedRB->getSingleSuccessor();
      ReplaceInstWithInst(ClonedRB->getTerminator(),
                          BranchInst::Create(Succ));
    }
  }
  if (TaskResumeBlocks) {
    NamedRegionTimer NRT("FixupTaskResume", "Fixup task-resume blocks",
                         TimerGroupName, TimerGroupDescription,
                         TimePassesIsEnabled);
    for (BasicBlock *TaskResumeBlk : *TaskResumeBlocks) {
      // Skip blocks that are not terminated by a detached.rethrow or
      // taskframe.resume.
      if (!isDetachedRethrow(TaskResumeBlk->getTerminator()) &&
          !isTaskFrameResume(TaskResumeBlk->getTerminator()))
        continue;

      BasicBlock *ClonedDRB = cast<BasicBlock>(VMap[TaskResumeBlk]);
      // If this exit block terminates in a detached.rethrow or
      // taskframe.resume, replace the terminator with a resume.
      InvokeInst *II = cast<InvokeInst>(ClonedDRB->getTerminator());
      Value *RethrowArg = II->getArgOperand(1);
      ReplaceInstWithInst(ClonedDRB->getTerminator(),
                          ResumeInst::Create(RethrowArg));
    }
  }

  for (DISubprogram *ISP : DIFinder.subprograms())
    if (ISP != SP)
      VMap.MD()[ISP].reset(ISP);

  for (DICompileUnit *CU : DIFinder.compile_units())
    VMap.MD()[CU].reset(CU);

  for (DIType *Type : DIFinder.types())
    VMap.MD()[Type].reset(Type);

  // Loop over all of the instructions in the function, fixing up operand
  // references as we go.  This uses VMap to do all the hard work.
  {
  NamedRegionTimer NRT("RemapBlock", "Remap instructions in block",
                       TimerGroupName, TimerGroupDescription,
                       TimePassesIsEnabled);
  for (const BasicBlock *BB : Blocks) {
    BasicBlock *CBB = cast<BasicBlock>(VMap[BB]);
    LLVM_DEBUG(dbgs() << "In block " << CBB->getName() << "\n");
    // Loop over all instructions, fixing each one as we find it...
    for (Instruction &II : *CBB) {
      LLVM_DEBUG(dbgs() << "  Remapping " << II << "\n");
      RemapInstruction(&II, VMap,
                       ModuleLevelChanges ? RF_None : RF_NoModuleLevelChanges,
                       TypeMapper, Materializer);
    }
  }

  // Remapping instructions could cause the Materializer to insert new
  // instructions in the entry block. Now remap the instructions in the entry
  // block.
  if (Materializer)
    while (!Materializer->BlocksToRemap.empty()) {
      BasicBlock *BB = Materializer->BlocksToRemap.pop_back_val();
      for (Instruction &II : *BB) {
        LLVM_DEBUG(dbgs() << "  Remapping " << II << "\n");
        RemapInstruction(&II, VMap,
                         ModuleLevelChanges ? RF_None : RF_NoModuleLevelChanges,
                         TypeMapper, Materializer);
      }
    }
  } // end timed region

  // Register all DICompileUnits of the old parent module in the new parent
  // module
  auto *OldModule = OldFunc->getParent();
  auto *NewModule = NewFunc->getParent();
  if (OldModule && NewModule && OldModule != NewModule &&
      DIFinder.compile_unit_count()) {
    auto *NMD = NewModule->getOrInsertNamedMetadata("llvm.dbg.cu");
    // Avoid multiple insertions of the same DICompileUnit to NMD.
    SmallPtrSet<const void *, 8> Visited;
    for (auto *Operand : NMD->operands())
      Visited.insert(Operand);
    for (auto *Unit : DIFinder.compile_units())
      // VMap.MD()[Unit] == Unit
      if (Visited.insert(Unit).second)
        NMD->addOperand(Unit);
  }
}

/// Create a helper function whose signature is based on Inputs and
/// Outputs as follows: f(in0, ..., inN, out0, ..., outN)
///
/// TODO: Fix the std::vector part of the type of this function.
Function *llvm::CreateHelper(
    const ValueSet &Inputs, const ValueSet &Outputs,
    std::vector<BasicBlock *> Blocks, BasicBlock *Header,
    const BasicBlock *OldEntry, const BasicBlock *OldExit,
    ValueToValueMapTy &VMap, Module *DestM, bool ModuleLevelChanges,
    SmallVectorImpl<ReturnInst *> &Returns, const StringRef NameSuffix,
    SmallPtrSetImpl<BasicBlock *> *ReattachBlocks,
    SmallPtrSetImpl<BasicBlock *> *DetachRethrowBlocks,
    SmallPtrSetImpl<BasicBlock *> *SharedEHEntries,
    const BasicBlock *OldUnwind,
    SmallPtrSetImpl<BasicBlock *> *UnreachableExits,
    Type *ReturnType, ClonedCodeInfo *CodeInfo,
    ValueMapTypeRemapper *TypeMapper, OutlineMaterializer *Materializer) {
  LLVM_DEBUG(dbgs() << "inputs: " << Inputs.size() << "\n");
  LLVM_DEBUG(dbgs() << "outputs: " << Outputs.size() << "\n");

  Function *OldFunc = Header->getParent();
  Type *RetTy = ReturnType;
  bool VoidRet = false;
  if (!RetTy)
    RetTy = Type::getVoidTy(Header->getContext());
  if (Type::getVoidTy(Header->getContext()) == RetTy)
    VoidRet = true;

  std::vector<Type *> paramTy;

  // Add the types of the input values to the function's argument list
  for (Value *value : Inputs) {
    LLVM_DEBUG(dbgs() << "value used in func: " << *value << "\n");
    paramTy.push_back(value->getType());
  }

  // Add the types of the output values to the function's argument list.
  for (Value *output : Outputs) {
    LLVM_DEBUG(dbgs() << "instr used in func: " << *output << "\n");
    paramTy.push_back(PointerType::getUnqual(output->getType()));
  }

  LLVM_DEBUG({
      dbgs() << "Function type: " << *RetTy << " f(";
      for (Type *i : paramTy)
	dbgs() << *i << ", ";
      dbgs() << ")\n";
    });

  FunctionType *FTy = FunctionType::get(RetTy, paramTy, false);

  // Create the new function
  Function *NewFunc = Function::Create(
      FTy, OldFunc->getLinkage(),
      OldFunc->getName() + ".outline_" + Header->getName() + NameSuffix, DestM);

  // Set names for input and output arguments.  At the same time, analyze
  // notable arguments, such as vector arguments.
  bool VectorArg = false;
  uint64_t MaxVectorArgWidth = 0;
  Function::arg_iterator DestI = NewFunc->arg_begin();
  for (Value *I : Inputs) {
    if (VMap.count(I) == 0) {       // Is this argument preserved?
      DestI->setName(I->getName()+NameSuffix); // Copy the name over...
      VMap[I] = &*DestI++;          // Add mapping to VMap
    }
    // Check for any vector arguments, and record the maximum width of any
    // vector argument we find.
    if (VectorType *VT = dyn_cast<VectorType>(I->getType())) {
      VectorArg = true;
      ElementCount EC = VT->getElementCount();
      if (EC.Scalable)
        // If we have a scalable vector, give up.
        MaxVectorArgWidth = std::numeric_limits<uint64_t>::max();
      else {
        unsigned VectorArgWidth = EC.Min * VT->getScalarSizeInBits();
        if (MaxVectorArgWidth < VectorArgWidth)
          MaxVectorArgWidth = VectorArgWidth;
      }
    }
  }
  for (Value *I : Outputs)
    if (VMap.count(I) == 0) {              // Is this argument preserved?
      DestI->setName(I->getName()+NameSuffix); // Copy the name over...
      VMap[I] = &*DestI++;                 // Add mapping to VMap
    }

  // Copy all attributes other than those stored in the AttributeSet.  We need
  // to remap the parameter indices of the AttributeSet.
  AttributeList NewAttrs = NewFunc->getAttributes();
  NewFunc->copyAttributesFrom(OldFunc);
  NewFunc->setAttributes(NewAttrs);

  // Fix up the personality function that got copied over.
  if (OldFunc->hasPersonalityFn())
    NewFunc->setPersonalityFn(
        MapValue(OldFunc->getPersonalityFn(), VMap,
                 ModuleLevelChanges ? RF_None : RF_NoModuleLevelChanges,
                 TypeMapper, Materializer));

  SmallVector<AttributeSet, 4> NewArgAttrs(NewFunc->arg_size());
  AttributeList OldAttrs = OldFunc->getAttributes();

  // Clone any argument attributes
  {
  NamedRegionTimer NRT("CloneArgAttrs", "Clone argument attributes",
                       TimerGroupName, TimerGroupDescription,
                       TimePassesIsEnabled);
  for (Argument &OldArg : OldFunc->args()) {
    // Check if we're passing this argument to the helper.  We check Inputs here
    // instead of the VMap to avoid potentially populating the VMap with a null
    // entry for the old argument.
    if (Inputs.count(&OldArg) || Outputs.count(&OldArg)) {
      Argument *NewArg = dyn_cast<Argument>(VMap[&OldArg]);
      NewArgAttrs[NewArg->getArgNo()] =
          OldAttrs.getParamAttributes(OldArg.getArgNo())
          .removeAttribute(NewFunc->getContext(), Attribute::Returned);
    }
  }
  } // end timed region

  NewFunc->setAttributes(
      AttributeList::get(NewFunc->getContext(), OldAttrs.getFnAttributes(),
                         OldAttrs.getRetAttributes(), NewArgAttrs));

  // Remove old return attributes.
  NewFunc->removeAttributes(
      AttributeList::ReturnIndex,
      AttributeFuncs::typeIncompatible(NewFunc->getReturnType()));

  // Update vector-related attributes in the caller and new function
  if (VectorArg && OldFunc->hasFnAttribute("min-legal-vector-width")) {
    uint64_t CallerVectorWidth;
    OldFunc->getFnAttribute("min-legal-vector-width")
        .getValueAsString()
        .getAsInteger(0, CallerVectorWidth);
    if (std::numeric_limits<uint64_t>::max() == MaxVectorArgWidth) {
      // MaxVectorArgWidth is not a finite value.  Give up and remove the
      // min-legal-vector-width attribute, so OldFunc wil be treated
      // conservatively henceforth.
      OldFunc->removeFnAttr("min-legal-vector-width");
      // Update the min-legal-vector-width in the new function as well
      NewFunc->removeFnAttr("min-legal-vector-width");
    } else if (MaxVectorArgWidth > CallerVectorWidth) {
      // If MaxVectorArgWidth is a finite value and larger than the
      // min-legal-vector-width of OldFunc, then set the
      // min-legal-vector-width of OldFunc to match MaxVectorArgWidth.
      OldFunc->addFnAttr("min-legal-vector-width",
                         llvm::utostr(MaxVectorArgWidth));
      // Update the min-legal-vector-width in the new function
      NewFunc->addFnAttr("min-legal-vector-width",
                         llvm::utostr(MaxVectorArgWidth));
    }
  }

  // Clone the metadata from the old function into the new.
  bool MustCloneSP =
      OldFunc->getParent() && OldFunc->getParent() == NewFunc->getParent();
  DISubprogram *SP = OldFunc->getSubprogram();
  if (SP) {
    assert(!MustCloneSP || ModuleLevelChanges);
    // Add mappings for some DebugInfo nodes that we don't want duplicated
    // even if they're distinct.
    auto &MD = VMap.MD();
    MD[SP->getUnit()].reset(SP->getUnit());
    MD[SP->getType()].reset(SP->getType());
    MD[SP->getFile()].reset(SP->getFile());
    // If we're not cloning into the same module, no need to clone the
    // subprogram
    if (!MustCloneSP)
      MD[SP].reset(SP);
  }

  {
  NamedRegionTimer NRT("MapMetadata", "Map function metadata",
                       TimerGroupName, TimerGroupDescription,
                       TimePassesIsEnabled);
  SmallVector<std::pair<unsigned, MDNode *>, 1> MDs;
  OldFunc->getAllMetadata(MDs);
  for (auto MD : MDs) {
    NewFunc->addMetadata(
        MD.first,
        *MapMetadata(MD.second, VMap,
                     ModuleLevelChanges ? RF_None : RF_NoModuleLevelChanges,
                     TypeMapper, Materializer));
  }
  } // end timed region

  // We assume that the Helper reads and writes its arguments.  If the parent
  // function had stronger attributes on memory access -- specifically, if the
  // parent is marked as only reading memory -- we must replace this attribute
  // with an appropriate weaker form.
  if (OldFunc->onlyReadsMemory()) {
    NewFunc->removeFnAttr(Attribute::ReadNone);
    NewFunc->removeFnAttr(Attribute::ReadOnly);
    NewFunc->setOnlyAccessesArgMemory();
  }

  // Inherit the calling convention from the parent.
  NewFunc->setCallingConv(OldFunc->getCallingConv());

  // The new function needs a root node because other nodes can branch to the
  // head of the region, but the entry node of a function cannot have preds.
  BasicBlock *NewEntry = BasicBlock::Create(
      Header->getContext(), OldEntry->getName()+NameSuffix, NewFunc);
  // The new function also needs an exit node.
  BasicBlock *NewExit = BasicBlock::Create(
      Header->getContext(), OldExit->getName()+NameSuffix);

  // Add mappings to the NewEntry and NewExit.
  VMap[OldEntry] = NewEntry;
  VMap[OldExit] = NewExit;

  BasicBlock *NewUnwind = nullptr;
  // Create a new unwind destination for the cloned blocks if it's needed.
  if (OldUnwind) {
    NewUnwind = BasicBlock::Create(
        NewFunc->getContext(), OldUnwind->getName()+NameSuffix);
    VMap[OldUnwind] = NewUnwind;
  }

  // Create an new unreachable exit block, if needed.
  BasicBlock *NewUnreachable = nullptr;
  if (UnreachableExits && !UnreachableExits->empty()) {
    NewUnreachable = BasicBlock::Create(
        NewFunc->getContext(), "unreachable"+NameSuffix);
    new UnreachableInst(NewFunc->getContext(), NewUnreachable);
    for (BasicBlock *Unreachable : *UnreachableExits)
      VMap[Unreachable] = NewUnreachable;
  }

  // Clone Blocks into the new function.
  CloneIntoFunction(NewFunc, OldFunc, Blocks, VMap, ModuleLevelChanges,
                    Returns, NameSuffix, ReattachBlocks, DetachRethrowBlocks,
                    SharedEHEntries, SP, CodeInfo, TypeMapper, Materializer);

  // Add a branch in the new function to the cloned Header.
  BranchInst::Create(cast<BasicBlock>(VMap[Header]), NewEntry);
  NewExit->insertInto(NewFunc);
  // Add a return in the new function, with a default null value if necessary.
  if (VoidRet)
    ReturnInst::Create(Header->getContext(), NewExit);
  else
    ReturnInst::Create(Header->getContext(), Constant::getNullValue(RetTy),
                       NewExit);

  // If needed, create a landingpad and resume for the unwind destination in the
  // new function.
  if (OldUnwind) {
    NewUnwind->insertInto(NewFunc);
    LandingPadInst *LPad =
      LandingPadInst::Create(OldUnwind->getLandingPadInst()->getType(), 0,
                             "lpadval", NewUnwind);
    LPad->setCleanup(true);
    ResumeInst::Create(LPad, NewUnwind);
  }

  // If needed, add the new unreachable destination.
  if (NewUnreachable)
    NewUnreachable->insertInto(NewFunc);

  return NewFunc;
}

// Add alignment assumptions to parameters of outlined function, based on known
// alignment data in the caller.
void llvm::AddAlignmentAssumptions(
    const Function *Caller, const ValueSet &Args, ValueToValueMapTy &VMap,
    const Instruction *CallSite, AssumptionCache *AC, DominatorTree *DT) {
  NamedRegionTimer NRT("AddAlignmentAssumptions", "Add alignment assumptions",
                       TimerGroupName, TimerGroupDescription,
                       TimePassesIsEnabled);
  auto &DL = Caller->getParent()->getDataLayout();
  for (Value *ArgVal : Args) {
    // Ignore arguments to non-pointer types
    if (!ArgVal->getType()->isPointerTy()) continue;
    Argument *Arg = cast<Argument>(VMap[ArgVal]);
    // Ignore arguments to non-pointer types
    if (!Arg->getType()->isPointerTy()) continue;
    // If the argument already has an alignment attribute, skip it.
    if (Arg->getParamAlignment()) continue;
    // Get any known alignment information for this argument's value.
    Align Alignment = getKnownAlignment(ArgVal, DL, CallSite, AC, DT);
    // If we have alignment data, add it as an attribute to the outlined
    // function's parameter.
    if (Alignment >= 1)
      Arg->addAttr(Attribute::getWithAlignment(Arg->getContext(), Alignment));
  }
}
