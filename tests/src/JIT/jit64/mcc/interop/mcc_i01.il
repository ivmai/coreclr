// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.


.assembly extern mscorlib {}
.assembly MCCTest {}
.module mcc_i01.exe


.namespace MCCTest
{
  .class MyClass
  {
    .method assembly static pinvokeimpl("native_i0c" as "#1" cdecl) 
        vararg valuetype MCCTest.VType0 Sum(unsigned int64) cil managed preservesig {
    }

    .method private static int32 Main(string[] args)
    {
      .entrypoint
      .maxstack  64
      .locals init	(
        [0] valuetype MCCTest.VType0 res,
        [1] int32 rc
      )
      
      ldc.i8 1
      ldc.i8 2
      ldc.i8 3
      ldc.i8 4
      ldc.i8 5
      ldc.i8 6
      ldc.i8 7
      ldc.i8 8
      ldc.i8 9
      ldc.i8 10
      ldc.i8 11
      ldc.i8 12
      ldc.i8 1
      neg
      ldftn   vararg valuetype MCCTest.VType0 MCCTest.MyClass::Sum(unsigned int64)
      calli   vararg valuetype MCCTest.VType0(unsigned int64, ..., 
                                                unsigned int64, 
                                                unsigned int64, 
                                                unsigned int64, 
                                                unsigned int64, 
                                                unsigned int64, 
                                                unsigned int64, 
                                                unsigned int64, 
                                                unsigned int64, 
                                                unsigned int64, 
                                                unsigned int64, 
                                                unsigned int64, 
                                                unsigned int64)
      stloc.s    res

      // Check Result
      ldloc.s    res
      ldc.i4     12
      call       int32 MCCTest.Common::CheckResult(valuetype MCCTest.VType0, int32)
      stloc.s    rc
      
      ldloc.s    rc
      ret
    } // end of method MyClass::Main

  } // end of class MyClass

} // end of namespace MCCTest
