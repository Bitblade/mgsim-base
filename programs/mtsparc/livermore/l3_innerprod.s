/*
    Livermore kernel 3 -- Inner product

    double z[1001], x[1001];
    double q = 0.0;
    for (int k = 0; k < n; k++)
    {
        q += z[k] * x[k];
    }
*/
    .file "l3_innerprod.s"

    .section .rodata
    .ascii "\0TEST_INPUTS:R10:512\0"

    .text
    
!
! Main thread
!
! %11 = N
!
    .globl main
    .align 64
main:
    set     X, %1           ! %1 = X
    set     Y, %2           ! %2 = Y
    
    allocate %0, %4
    setlimit %4, %11
    cred    loop, %4
    
    putg    %1,  %4, 0
    putg    %2,  %4, 1
    fputs   %f0, %4, 0
    fputs   %f0, %4, 1      ! %df0,%df1 = sum = 0

    sync    %4, %1
    release %4
    mov     %1, %0
    end

!
! Loop thread
!
! %g0 = X
! %g1 = Y
! %d0 = sum
! %l0 = i
    .globl loop
    .align 64
    .registers 2 0 2 0 2 4
loop:
    sll     %l0, 3, %l0
    add     %l0, %g1, %l1
    ldd     [%l1], %lf2
    add     %l0, %g0, %l0
    ldd     [%l0], %lf0
    fmuld   %lf0, %lf2, %lf0; swch
    faddd   %df0, %lf0, %lf0; swch
    fmovs   %lf0, %sf0; swch
    fmovs   %lf1, %sf1
    end

    .section .bss
    .align 64
X:  .skip 1001 * 8
    .align 64
Y:  .skip 1001 * 8
