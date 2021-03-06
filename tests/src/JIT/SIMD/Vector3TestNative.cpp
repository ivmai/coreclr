// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.

#include <stdio.h>
#include <string.h>

#if defined(__clang__)
#define EXPORT(type) __attribute__((visibility("default"))) extern "C" type
#elif defined(_MSC_VER)
#define EXPORT(type) extern "C" __declspec(dllexport) type
#else // defined(__clang__)
#define EXPORT(type) type
#endif // !defined(__clang__)

#if !defined(_MSC_VER)
#if __i386__
#define __stdcall __attribute__((stdcall))
#else // __i386__
#define __stdcall
#endif  // !__i386__
#endif // !defined(_MSC_VER)

typedef struct _Vector3 
{
    float x;
    float y;
    float z;    
} Vector3;

typedef struct _DT 
{
   Vector3 a;
   Vector3 b;
} DT; 

typedef struct _ComplexDT 
{
    int iv;
    DT vecs;
    char str[256];
    Vector3 v3;
} ComplexDT;

//
// PInvoke native call for Vector3 size check
//

EXPORT(int) __stdcall nativeCall_PInvoke_CheckVector3Size() 
{
    printf("nativeCall_PInvoke_CheckVector3Size: sizeof(Vector3) == %d\n", (int)sizeof(Vector3));
    fflush(stdout);
    return sizeof(Vector3);
}

//
// PInvoke native call for Vector3 argument
//

EXPORT(float) __stdcall nativeCall_PInvoke_Vector3Arg(int i, Vector3 v1, char* s, Vector3 v2) 
{
    float sum0 = v1.x + v1.y + v1.z;
    float sum1 = v2.x + v2.y + v2.z;
    printf("nativeCall_PInvoke_Vector3Arg:\n");
    printf("    iVal %d\n", i);
    printf("    sumOfEles(%f, %f, %f) = %f\n", v1.x, v1.y, v1.z, sum0);
    printf("    str  %s\n", s);
    printf("    sumOfEles(%f, %f, %f) = %f\n", v2.x, v2.y, v2.z, sum1);
    fflush(stdout);
    if ((strncmp(s, "abcdefg", strnlen(s, 32)) != 0) || i != 123) {
        return 0;
    }    
    return sum0 + sum1;
}

//
// PInvoke native call for Vector3 argument
//

EXPORT(Vector3) __stdcall nativeCall_PInvoke_Vector3Ret() 
{
    Vector3 ret;
    ret.x = 1;
    ret.y = 2;
    ret.z = 3;
    float sum = ret.x + ret.y + ret.z;
    printf("nativeCall_PInvoke_Vector3Ret:\n");
    printf("    Return value: (%f, %f, %f)\n", ret.x, ret.y, ret.z);
    printf("    Sum of return scalar values = %f\n", sum);
    fflush(stdout);
    return ret;
}

//
// PInvoke native call for Vector3 array
//

EXPORT(float) __stdcall nativeCall_PInvoke_Vector3Array(Vector3* arr) 
{
    float sum = 0.0;
    printf("nativeCall_PInvoke_Vector3Array\n");
    for (unsigned i = 0; i < 2; ++i) 
    {
        Vector3* e = &arr[i];
        printf("    arrEle[%d]: %f %f %f\n", i, e->x, e->y, e->z);
        sum += e->x + e->y + e->z;
    }
    printf("    Sum = %f\n", sum);
    fflush(stdout);
    return sum;
}

//
// PInvoke native call for Vector3 in struct
//

EXPORT(DT) __stdcall nativeCall_PInvoke_Vector3InStruct(DT data) 
{
    printf("nativeCall_PInvoke_Vector3InStruct\n");
    DT ret;
    ret.a.x = data.a.x + 1;
    ret.a.y = data.a.y + 1;
    ret.a.z = data.a.z + 1;
    ret.b.x = data.b.x + 1;
    ret.b.y = data.b.y + 1;
    ret.b.z = data.b.z + 1;
    printf("    First struct memeber: (%f %f %f) -> (%f %f %f)\n", 
        data.a.x, data.a.y, data.a.z, ret.a.x, ret.a.y, ret.a.z);
    printf("    Second struct member: (%f %f %f) -> (%f %f %f)\n", 
        data.b.x, data.b.y, data.b.z, ret.b.x, ret.b.y, ret.b.z);
    float sum = ret.a.x + ret.a.y + ret.a.z + ret.b.x + ret.b.y + ret.b.z;
    printf("    Sum of all return scalar values = %f\n", sum);
    fflush(stdout);
    return ret;
}

//
// PInvoke native call for Vector3 in complex struct
//

EXPORT(void) __stdcall nativeCall_PInvoke_Vector3InComplexStruct(ComplexDT* arg) 
{
    static const char* ret_str = "ret_string";
    printf("nativeCall_PInvoke_Vector3InStruct\n");
    printf("    Arg ival: %d\n", arg->iv);
    printf("    Arg Vector3 v1: (%f %f %f)\n", arg->vecs.a.x, arg->vecs.a.y, arg->vecs.a.z);
    printf("    Arg Vector3 v2: (%f %f %f)\n", arg->vecs.b.x, arg->vecs.b.y, arg->vecs.b.z);
    printf("    Arg Vector3 v3: (%f %f %f)\n", arg->v3.x, arg->v3.y, arg->v3.z);
    printf("    Arg string arg: %s\n", arg->str);        
   

    arg->vecs.a.x = arg->vecs.a.x + 1;
    arg->vecs.a.y = arg->vecs.a.y + 1;
    arg->vecs.a.z = arg->vecs.a.z + 1;
    arg->vecs.b.x = arg->vecs.b.x + 1;
    arg->vecs.b.y = arg->vecs.b.y + 1;
    arg->vecs.b.z = arg->vecs.b.z + 1;
    arg->v3.x = arg->v3.x + 1;
    arg->v3.y = arg->v3.y + 1;
    arg->v3.z = arg->v3.z + 1;    
    arg->iv = arg->iv + 1;
    strncpy(arg->str, ret_str, strnlen("ret_str", 32));
    
    printf("    Return ival: %d\n", arg->iv);
    printf("    Return Vector3 v1: (%f %f %f)\n", arg->vecs.a.x, arg->vecs.a.y, arg->vecs.a.z);
    printf("    Return Vector3 v2: (%f %f %f)\n", arg->vecs.b.x, arg->vecs.b.y, arg->vecs.b.z);
    printf("    Return Vector3 v3: (%f %f %f)\n", arg->v3.x, arg->v3.y, arg->v3.z);
    printf("    Return string arg: %s\n", arg->str);        
    float sum = arg->vecs.a.x + arg->vecs.a.y + arg->vecs.a.z 
        + arg->vecs.b.x + arg->vecs.b.y + arg->vecs.b.z
        + arg->v3.x + arg->v3.y + arg->v3.z;
    printf("    Sum of all return float scalar values = %f\n", sum);
    fflush(stdout);    
}
    
//
// RPInvoke native call for Vector3 argument
//
typedef void (__stdcall *CallBack_RPInvoke_Vector3Arg)(int i, Vector3 v1, char* s, Vector3 v2);


EXPORT(void) __stdcall nativeCall_RPInvoke_Vector3Arg(
  CallBack_RPInvoke_Vector3Arg notify)
{
    int i = 123;    
    const static char* str = "abcdefg";
    Vector3 v1, v2;
    v1.x = 1; v1.y = 2; v1.z = 3;
    v2.x = 10; v2.y = 20; v2.z = 30;
    notify(i, v1, (char*)str, v2);
} 

//
// RPInvoke native call for Vector3 array
//

typedef Vector3 (__stdcall *CallBack_RPInvoke_Vector3Ret)();

EXPORT(bool) __stdcall nativeCall_RPInvoke_Vector3Ret(
  CallBack_RPInvoke_Vector3Ret notify)
{
    Vector3 ret = notify();
    printf("nativeCall_RPInvoke_Vector3Ret: Return value (%f %f %f)\n",
        ret.x, ret.y, ret.z);
    fflush(stdout);
    if (ret.x == 1 && ret.y == 2 && ret.z == 3) {
        return true;
    }
    return false;
} 

//
// RPInvoke native call for Vector3 array
//

typedef void (__stdcall *CallBack_RPInvoke_Vector3Array)(Vector3* v, int size);

static Vector3 arr[2];

EXPORT(void) __stdcall nativeCall_RPInvoke_Vector3Array(
  CallBack_RPInvoke_Vector3Array notify, 
  int a)
{
    arr[0].x = a + 1; arr[0].y = a + 2; arr[0].z = a + 3;
    arr[1].x = a + 10; arr[1].y = a + 20; arr[1].z = a + 30;
    notify(arr, 2);
} 

//
// RPInvoke native call for Vector3-in-struct test
//

typedef void (__stdcall *CallBack_RPInvoke_Vector3InStruct)(DT v);

static DT v;

EXPORT(void) __stdcall nativeCall_RPInvoke_Vector3InStruct(
  CallBack_RPInvoke_Vector3InStruct notify, 
  int a)
{
    v.a.x = a + 1; v.a.y = a + 2; v.a.z = a + 3;
    v.b.x = a + 10; v.b.y = a + 20; v.b.z = a + 30;
    notify(v);
}

//
// RPInvoke native call for complex Vector3-in-struct test
//

typedef bool (__stdcall *CallBack_RPInvoke_Vector3InComplexStruct)(ComplexDT* v);

EXPORT(bool) __stdcall nativeCall_RPInvoke_Vector3InComplexStruct(
  CallBack_RPInvoke_Vector3InComplexStruct notify)
{
    static ComplexDT cdt;
    cdt.iv = 99;
    strncpy(cdt.str, "arg_string", strnlen("arg_string", 32));
    cdt.vecs.a.x = 1; cdt.vecs.a.y = 2; cdt.vecs.a.z = 3;
    cdt.vecs.b.x = 5; cdt.vecs.b.y = 6; cdt.vecs.b.z = 7;
    cdt.v3.x = 10; cdt.v3.y = 20; cdt.v3.z = 30;    
    
    notify(&cdt);
    
    printf("    Native ival: %d\n", cdt.iv);
    printf("    Native Vector3 v1: (%f %f %f)\n", cdt.vecs.a.x, cdt.vecs.a.y, cdt.vecs.a.z);
    printf("    Native Vector3 v2: (%f %f %f)\n", cdt.vecs.b.x, cdt.vecs.b.y, cdt.vecs.b.z);
    printf("    Native Vector3 v3: (%f %f %f)\n", cdt.v3.x, cdt.v3.y, cdt.v3.z);
    printf("    Native string arg: %s\n", cdt.str); 
    fflush(stdout);
    
    // Expected return value = 2 + 3 + 4 + 6 + 7 + 8 + 11 + 12 + 13 = 93
    float sum = cdt.vecs.a.x + cdt.vecs.a.y + cdt.vecs.a.z
        + cdt.vecs.b.x + cdt.vecs.b.y + cdt.vecs.b.z 
        + cdt.v3.x + cdt.v3.y + cdt.v3.z;
        
    if ((sum != 93) || (cdt.iv != 100) || (strcmp(cdt.str, "ret_string")!=0) )
    {
        return false;            
    }    
    return true;
}
