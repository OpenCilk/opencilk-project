add_llvm_component_library(LLVMTapirOpts
  CilkABI.cpp
  CilkRTSCilkFor.cpp
  CudaABI.cpp
  DRFScopedNoAliasAA.cpp
  LoopSpawningTI.cpp
  LoopStripMine.cpp
  LoopStripMinePass.cpp
  LoweringUtils.cpp
  OpenCilkABI.cpp
  OpenMPABI.cpp
  Outline.cpp
  QthreadsABI.cpp
  SerialABI.cpp
  SerializeSmallTasks.cpp
  Tapir.cpp
  TapirToTarget.cpp
  TapirLoopInfo.cpp

  ADDITIONAL_HEADER_DIRS
  ${LLVM_MAIN_INCLUDE_DIR}/llvm/Transforms
  ${LLVM_MAIN_INCLUDE_DIR}/llvm/Transforms/Tapir

  DEPENDS
  intrinsics_gen
  LLVMLinker
  )
