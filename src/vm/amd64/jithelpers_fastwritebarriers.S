// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.

.intel_syntax noprefix
#include "unixasmmacros.inc"


        .balign 8
LEAF_ENTRY JIT_WriteBarrier_PreGrow64, _TEXT
        // Do the move into the GC .  It is correct to take an AV here, the EH code
        // figures out that this came from a WriteBarrier and correctly maps it back
        // to the managed method which called the WriteBarrier (see setup in
        // InitializeExceptionHandling, vm\exceptionhandling.cpp).
        mov     [rdi], rsi

        NOP_3_BYTE // padding for alignment of constant

        // Can't compare a 64 bit immediate, so we have to move it into a
        // register.  Value of this immediate will be patched at runtime.
PATCH_LABEL JIT_WriteBarrier_PreGrow64_Patch_Label_Lower
        movabs  rax, 0xF0F0F0F0F0F0F0F0

        // Check the lower ephemeral region bound.
        cmp     rsi, rax
        .byte 0x72, 0x23
        // jb      Exit_PreGrow64

        nop // padding for alignment of constant

PATCH_LABEL JIT_WriteBarrier_PreGrow64_Patch_Label_CardTable
        movabs  rax, 0xF0F0F0F0F0F0F0F0

        // Touch the card table entry, if not already dirty.
        shr     rdi, 0Bh
        cmp     byte ptr [rdi + rax], 0FFh
        .byte 0x75, 0x02
        // jne     UpdateCardTable_PreGrow64
        REPRET

    UpdateCardTable_PreGrow64:
        mov     byte ptr [rdi + rax], 0FFh
        ret

    .balign 16
    Exit_PreGrow64:
        REPRET
LEAF_END_MARKED JIT_WriteBarrier_PreGrow64, _TEXT


        .balign 8
// See comments for JIT_WriteBarrier_PreGrow (above).
LEAF_ENTRY JIT_WriteBarrier_PostGrow64, _TEXT
        // Do the move into the GC .  It is correct to take an AV here, the EH code
        // figures out that this came from a WriteBarrier and correctly maps it back
        // to the managed method which called the WriteBarrier (see setup in
        // InitializeExceptionHandling, vm\exceptionhandling.cpp).
        mov     [rdi], rsi

        NOP_3_BYTE // padding for alignment of constant

        // Can't compare a 64 bit immediate, so we have to move them into a
        // register.  Values of these immediates will be patched at runtime.
        // By using two registers we can pipeline better.  Should we decide to use
        // a special non-volatile calling convention, this should be changed to
        // just one.
PATCH_LABEL JIT_WriteBarrier_PostGrow64_Patch_Label_Lower
        movabs  rax, 0xF0F0F0F0F0F0F0F0

        // Check the lower and upper ephemeral region bounds
        cmp     rsi, rax
        .byte 0x72,0x33
        // jb      Exit_PostGrow64

        nop // padding for alignment of constant

PATCH_LABEL JIT_WriteBarrier_PostGrow64_Patch_Label_Upper
        movabs  r8, 0xF0F0F0F0F0F0F0F0

        cmp     rsi, r8
        .byte 0x73,0x23
        // jae     Exit_PostGrow64

        nop // padding for alignment of constant

PATCH_LABEL JIT_WriteBarrier_PostGrow64_Patch_Label_CardTable
        movabs  rax, 0xF0F0F0F0F0F0F0F0

        // Touch the card table entry, if not already dirty.
        shr     rdi, 0Bh
        cmp     byte ptr [rdi + rax], 0FFh
        .byte 0x75, 0x02
        // jne     UpdateCardTable_PostGrow64
        REPRET

    UpdateCardTable_PostGrow64:
        mov     byte ptr [rdi + rax], 0FFh
        ret

    .balign 16
    Exit_PostGrow64:
        REPRET
LEAF_END_MARKED JIT_WriteBarrier_PostGrow64, _TEXT


#ifdef FEATURE_SVR_GC

        .balign 8
LEAF_ENTRY JIT_WriteBarrier_SVR64, _TEXT
        //
        // SVR GC has multiple heaps, so it cannot provide one single 
        // ephemeral region to bounds check against, so we just skip the
        // bounds checking all together and do our card table update 
        // unconditionally.
        //

        // Do the move into the GC .  It is correct to take an AV here, the EH code
        // figures out that this came from a WriteBarrier and correctly maps it back
        // to the managed method which called the WriteBarrier (see setup in
        // InitializeExceptionHandling, vm\exceptionhandling.cpp).
        mov     [rdi], rsi

        NOP_3_BYTE // padding for alignment of constant

PATCH_LABEL JIT_WriteBarrier_SVR64_PatchLabel_CardTable
        movabs  rax, 0xF0F0F0F0F0F0F0F0

        shr     rdi, 0Bh

        cmp     byte ptr [rdi + rax], 0FFh
        .byte 0x75, 0x02
        // jne     UpdateCardTable_SVR64
        REPRET

    UpdateCardTable_SVR64:
        mov     byte ptr [rdi + rax], 0FFh
        ret
LEAF_END_MARKED JIT_WriteBarrier_SVR64, _TEXT

#endif


#ifdef FEATURE_USE_SOFTWARE_WRITE_WATCH_FOR_GC_HEAP

        .balign 8
LEAF_ENTRY JIT_WriteBarrier_WriteWatch_PreGrow64, _TEXT
        // Regarding patchable constants:
        // - 64-bit constants have to be loaded into a register
        // - The constants have to be aligned to 8 bytes so that they can be patched easily
        // - The constant loads have been located to minimize NOP padding required to align the constants
        // - Using different registers for successive constant loads helps pipeline better. Should we decide to use a special
        //   non-volatile calling convention, this should be changed to use just one register.

        // Do the move into the GC .  It is correct to take an AV here, the EH code
        // figures out that this came from a WriteBarrier and correctly maps it back
        // to the managed method which called the WriteBarrier (see setup in
        // InitializeExceptionHandling, vm\exceptionhandling.cpp).
        mov     [rdi], rsi

        // Update the write watch table if necessary
        mov     rax, rdi
PATCH_LABEL JIT_WriteBarrier_WriteWatch_PreGrow64_Patch_Label_WriteWatchTable
        movabs  r10, 0xF0F0F0F0F0F0F0F0
        shr     rax, 0Ch // SoftwareWriteWatch::AddressToTableByteIndexShift
        NOP_2_BYTE // padding for alignment of constant
PATCH_LABEL JIT_WriteBarrier_WriteWatch_PreGrow64_Patch_Label_Lower
        movabs  r11, 0xF0F0F0F0F0F0F0F0
        add     rax, r10
        cmp     byte ptr [rax], 0h
        .byte 0x75, 0x03
        // jne     CheckCardTable_WriteWatch_PreGrow64
        mov     byte ptr [rax], 0FFh

    CheckCardTable_WriteWatch_PreGrow64:
        // Check the lower ephemeral region bound.
        cmp     rsi, r11
        .byte 0x72, 0x20
        // jb      Exit_WriteWatch_PreGrow64

        // Touch the card table entry, if not already dirty.
        shr     rdi, 0Bh
        NOP_2_BYTE // padding for alignment of constant
PATCH_LABEL JIT_WriteBarrier_WriteWatch_PreGrow64_Patch_Label_CardTable
        movabs  rax, 0xF0F0F0F0F0F0F0F0
        cmp     byte ptr [rdi + rax], 0FFh
        .byte 0x75, 0x02
        // jne     UpdateCardTable_WriteWatch_PreGrow64
        REPRET

    UpdateCardTable_WriteWatch_PreGrow64:
        mov     byte ptr [rdi + rax], 0FFh
        ret

    .balign 16
    Exit_WriteWatch_PreGrow64:
        REPRET
LEAF_END_MARKED JIT_WriteBarrier_WriteWatch_PreGrow64, _TEXT


        .balign 8
LEAF_ENTRY JIT_WriteBarrier_WriteWatch_PostGrow64, _TEXT
        // Regarding patchable constants:
        // - 64-bit constants have to be loaded into a register
        // - The constants have to be aligned to 8 bytes so that they can be patched easily
        // - The constant loads have been located to minimize NOP padding required to align the constants
        // - Using different registers for successive constant loads helps pipeline better. Should we decide to use a special
        //   non-volatile calling convention, this should be changed to use just one register.

        // Do the move into the GC .  It is correct to take an AV here, the EH code
        // figures out that this came from a WriteBarrier and correctly maps it back
        // to the managed method which called the WriteBarrier (see setup in
        // InitializeExceptionHandling, vm\exceptionhandling.cpp).
        mov     [rdi], rsi

        // Update the write watch table if necessary
        mov     rax, rdi
PATCH_LABEL JIT_WriteBarrier_WriteWatch_PostGrow64_Patch_Label_WriteWatchTable
        movabs  r10, 0xF0F0F0F0F0F0F0F0
        shr     rax, 0Ch // SoftwareWriteWatch::AddressToTableByteIndexShift
        NOP_2_BYTE // padding for alignment of constant
PATCH_LABEL JIT_WriteBarrier_WriteWatch_PostGrow64_Patch_Label_Lower
        movabs  r11, 0xF0F0F0F0F0F0F0F0
        add     rax, r10
        cmp     byte ptr [rax], 0h
        .byte 0x75, 0x06
        // jne     CheckCardTable_WriteWatch_PostGrow64
        mov     byte ptr [rax], 0FFh

        NOP_3_BYTE // padding for alignment of constant

        // Check the lower and upper ephemeral region bounds
    CheckCardTable_WriteWatch_PostGrow64:
        cmp     rsi, r11
        .byte 0x72, 0x3d
        // jb      Exit_WriteWatch_PostGrow64

        NOP_3_BYTE // padding for alignment of constant

PATCH_LABEL JIT_WriteBarrier_WriteWatch_PostGrow64_Patch_Label_Upper
        movabs  r10, 0xF0F0F0F0F0F0F0F0

        cmp     rsi, r10
        .byte 0x73, 0x2b
        // jae     Exit_WriteWatch_PostGrow64

        nop // padding for alignment of constant

PATCH_LABEL JIT_WriteBarrier_WriteWatch_PostGrow64_Patch_Label_CardTable
        movabs  rax, 0xF0F0F0F0F0F0F0F0

        // Touch the card table entry, if not already dirty.
        shr     rdi, 0Bh
        cmp     byte ptr [rdi + rax], 0FFh
        .byte 0x75, 0x02
        // jne     UpdateCardTable_WriteWatch_PostGrow64
        REPRET

    UpdateCardTable_WriteWatch_PostGrow64:
        mov     byte ptr [rdi + rax], 0FFh
        ret

    .balign 16
    Exit_WriteWatch_PostGrow64:
        REPRET
LEAF_END_MARKED JIT_WriteBarrier_WriteWatch_PostGrow64, _TEXT


#ifdef FEATURE_SVR_GC

        .balign 8
LEAF_ENTRY JIT_WriteBarrier_WriteWatch_SVR64, _TEXT
        // Regarding patchable constants:
        // - 64-bit constants have to be loaded into a register
        // - The constants have to be aligned to 8 bytes so that they can be patched easily
        // - The constant loads have been located to minimize NOP padding required to align the constants
        // - Using different registers for successive constant loads helps pipeline better. Should we decide to use a special
        //   non-volatile calling convention, this should be changed to use just one register.

        //
        // SVR GC has multiple heaps, so it cannot provide one single 
        // ephemeral region to bounds check against, so we just skip the
        // bounds checking all together and do our card table update 
        // unconditionally.
        //

        // Do the move into the GC .  It is correct to take an AV here, the EH code
        // figures out that this came from a WriteBarrier and correctly maps it back
        // to the managed method which called the WriteBarrier (see setup in
        // InitializeExceptionHandling, vm\exceptionhandling.cpp).
        mov     [rdi], rsi

        // Update the write watch table if necessary
        mov     rax, rdi
PATCH_LABEL JIT_WriteBarrier_WriteWatch_SVR64_PatchLabel_WriteWatchTable
        movabs  r10, 0xF0F0F0F0F0F0F0F0
        shr     rax, 0Ch // SoftwareWriteWatch::AddressToTableByteIndexShift
        NOP_2_BYTE // padding for alignment of constant
PATCH_LABEL JIT_WriteBarrier_WriteWatch_SVR64_PatchLabel_CardTable
        movabs  r11, 0xF0F0F0F0F0F0F0F0
        add     rax, r10
        cmp     byte ptr [rax], 0h
        .byte 0x75, 0x03
        // jne     CheckCardTable_WriteWatch_SVR64
        mov     byte ptr [rax], 0FFh

    CheckCardTable_WriteWatch_SVR64:
        shr     rdi, 0Bh
        cmp     byte ptr [rdi + r11], 0FFh
        .byte 0x75, 0x02
        // jne     UpdateCardTable_WriteWatch_SVR64
        REPRET

    UpdateCardTable_WriteWatch_SVR64:
        mov     byte ptr [rdi + r11], 0FFh
        ret
LEAF_END_MARKED JIT_WriteBarrier_WriteWatch_SVR64, _TEXT

#endif
#endif
