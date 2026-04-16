.extern return_slli_test
.extern fail

    .section .text.init
    .globl slli_test
    .type  slli_test, @function

slli_test:
    // shift by 0
    test1:
        li   t0, 0x123
        slli t2, t0, 0
        li   t3, 0x123
        beq  t2, t3, test2
        j Fail_Slli_1

    // shift by 1
    test2:
        li   t0, 0x5
        slli t2, t0, 1
        li   t3, 0xA
        beq  t2, t3, test3
        j Fail_Slli_2

    // shift by 4
    test3:
        li   t0, 0xF
        slli t2, t0, 4
        li   t3, 0xF0
        beq  t2, t3, test4
        j Fail_Slli_3

    // shift a 1 into sign bit
    test4:
        li   t0, 0x40000000
        slli t2, t0, 1
        li   t3, 0x80000000
        beq  t2, t3, test5
        j Fail_Slli_4

    // shift negative
    test5:
        li   t0, 0xFFFFFFFF
        slli t2, t0, 1
        li   t3, 0xFFFFFFFE
        beq  t2, t3, test6
        j Fail_Slli_5

    // shift from b0 to b31
    test6:
        li   t0, 0x1
        slli t2, t0, 31
        li   t3, 0x80000000
        beq  t2, t3, test7
        j Fail_Slli_6

    // shift out 1's to make a 0
    test7:
        li   t0, 0x80000000
        slli t2, t0, 1
        li   t3, 0
        beq  t2, t3, test8
        j Fail_Slli_7

    // fun shift
    test8:
        li   t0, 0x55555555
        slli t2, t0, 1
        li   t3, 0xAAAAAAAA
        beq  t2, t3, pass
        j Fail_Slli_8

pass:
    j return_slli_test

Fail_Slli_1:
    li gp, 601
    j fail

Fail_Slli_2:
    li gp, 602
    j fail

Fail_Slli_3:
    li gp, 603
    j fail

Fail_Slli_4:
    li gp, 604
    j fail

Fail_Slli_5:
    li gp, 605
    j fail

Fail_Slli_6:
    li gp, 606
    j fail

Fail_Slli_7:
    li gp, 607
    j fail

Fail_Slli_8:
    li gp, 608
    j fail
