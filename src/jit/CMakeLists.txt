set(CMAKE_INCLUDE_CURRENT_DIR ON)

include_directories("./jitstd")
include_directories("../inc")

# Enable the following for UNIX altjit on Windows
# add_definitions(-DALT_JIT)

if (CLR_CMAKE_TARGET_ARCH_AMD64)
  add_definitions(-DFEATURE_SIMD) 
  add_definitions(-DFEATURE_AVX_SUPPORT) 
endif ()

if (ARM_SOFTFP)
  add_definitions(-DARM_SOFTFP)
endif (ARM_SOFTFP)

set( JIT_SOURCES
  alloc.cpp
  assertionprop.cpp
  bitset.cpp
  block.cpp
  codegencommon.cpp
  compiler.cpp
  copyprop.cpp
  disasm.cpp
  earlyprop.cpp
  ee_il_dll.cpp
  eeinterface.cpp
  emit.cpp
  error.cpp
  flowgraph.cpp
  gcdecode.cpp
  gcencode.cpp
  gcinfo.cpp
  gentree.cpp
  gschecks.cpp
  hashbv.cpp
  hostallocator.cpp
  importer.cpp
  inline.cpp
  inlinepolicy.cpp
  instr.cpp
  jitconfig.cpp
  jiteh.cpp
  jittelemetry.cpp
  lclvars.cpp
  liveness.cpp
  loopcloning.cpp
  lower.cpp
  lsra.cpp
  morph.cpp
  optcse.cpp
  optimizer.cpp
  rangecheck.cpp
  rationalize.cpp
  regalloc.cpp
  register_arg_convention.cpp
  regset.cpp
  scopeinfo.cpp
  sharedfloat.cpp
  sm.cpp
  smdata.cpp
  smweights.cpp
  ssabuilder.cpp
  ssarenamestate.cpp
  typeinfo.cpp
  unwind.cpp
  utils.cpp
  valuenum.cpp
)

if(CLR_CMAKE_TARGET_ARCH_AMD64)
  set( ARCH_SOURCES
    codegenxarch.cpp
    emitxarch.cpp
    lowerxarch.cpp
    simd.cpp
    simdcodegenxarch.cpp
    targetamd64.cpp
    unwindamd64.cpp
  )
elseif(CLR_CMAKE_TARGET_ARCH_ARM)
  set( ARCH_SOURCES
    codegenarm.cpp
    emitarm.cpp
    lowerarm.cpp
    targetarm.cpp
    unwindarm.cpp
  )
elseif(CLR_CMAKE_TARGET_ARCH_I386)
  set( ARCH_SOURCES
    codegenxarch.cpp
    emitxarch.cpp
    lowerxarch.cpp
    simd.cpp
    simdcodegenxarch.cpp
    targetx86.cpp
  )
elseif(CLR_CMAKE_TARGET_ARCH_ARM64)
  set( ARCH_SOURCES
    codegenarm64.cpp
    emitarm64.cpp
    lowerarm64.cpp
    targetarm64.cpp
    unwindarm.cpp
    unwindarm64.cpp
  )
else()
  clr_unknown_arch()
endif()

# The following defines all the source files used by the "legacy" back-end (#ifdef LEGACY_BACKEND).
# It is always safe to include both legacy and non-legacy files in the build, as everything is properly
# #ifdef'ed, though it makes the build slightly slower to do so. Note there is only a legacy backend for
# x86 and ARM.

if(CLR_CMAKE_TARGET_ARCH_AMD64)
  set( ARCH_LEGACY_SOURCES
  )
elseif(CLR_CMAKE_TARGET_ARCH_ARM)
  set( ARCH_LEGACY_SOURCES
    codegenlegacy.cpp
    registerfp.cpp
  )
elseif(CLR_CMAKE_TARGET_ARCH_I386)
  set( ARCH_LEGACY_SOURCES
    codegenlegacy.cpp
    stackfp.cpp
  )
elseif(CLR_CMAKE_TARGET_ARCH_ARM64)
  set( ARCH_LEGACY_SOURCES
  )
else()
  clr_unknown_arch()
endif()

set( SOURCES
  ${JIT_SOURCES}
  ${ARCH_SOURCES}
  ${ARCH_LEGACY_SOURCES}
)

convert_to_absolute_path(SOURCES ${SOURCES})

if( WIN32 )

  add_precompiled_header(jitpch.h ../jitpch.cpp SOURCES)

  # Create .def file containing a list of exports preceeded by
  # 'EXPORTS'.  The file "ClrJit.exports" already contains the list, so we
  # massage it into the correct format here to create "ClrJit.exports.def".
  set(CLRJIT_EXPORTS_DEF ${CMAKE_CURRENT_BINARY_DIR}/ClrJit.exports.def)
  set(CLRJIT_EXPORTS_DEF_TEMP ${CLRJIT_EXPORTS_DEF}.txt)
  file(READ "ClrJit.exports" exports_list)
  file(WRITE ${CLRJIT_EXPORTS_DEF_TEMP} "LIBRARY CLRJIT\n")
  file(APPEND ${CLRJIT_EXPORTS_DEF_TEMP} "EXPORTS\n")
  file(APPEND ${CLRJIT_EXPORTS_DEF_TEMP} ${exports_list})

  # Copy the file only if it has changed.
  execute_process(COMMAND ${CMAKE_COMMAND} -E copy_if_different
    ${CLRJIT_EXPORTS_DEF_TEMP} ${CLRJIT_EXPORTS_DEF})

  set(SHARED_LIB_SOURCES ${SOURCES} ${CLRJIT_EXPORTS_DEF})
else()
  set(SHARED_LIB_SOURCES ${SOURCES})
endif()

set(CLR_EXPORTED_SYMBOL_FILE ${CLRJIT_EXPORTS_DEF})

set(JIT_BASE_NAME clrjit)
if (CLR_BUILD_JIT32)
  set(JIT_BASE_NAME ryujit)
endif()

add_subdirectory(dll)
add_subdirectory(crossgen)
add_subdirectory(standalone)

if (CLR_CMAKE_PLATFORM_ARCH_I386 OR CLR_CMAKE_PLATFORM_ARCH_ARM)
    add_subdirectory(protojit)
endif (CLR_CMAKE_PLATFORM_ARCH_I386 OR CLR_CMAKE_PLATFORM_ARCH_ARM)
