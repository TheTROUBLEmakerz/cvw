.extern return_srli_test
.extern fail

    .section .text.init
    .globl srli_test
    .type  srli_test, @function

srli_test:
    # shift by 0
    test1:
        li   t0, 0xABC
        srli t2, t0, 0
        li   t3, 0xABC
        beq  t2, t3, test2
        j Fail_Srli_1

    # shift right by 1
    test2:
        li   t0, 0xA
        srli t2, t0, 1
        li   t3, 0x5
        beq  t2, t3, test3
        j Fail_Srli_2

    # shift right by 4
    test3:
        li   t0, 0xF0
        srli t2, t0, 4
        li   t3, 0xF
        beq  t2, t3, test4
        j Fail_Srli_3

    # shift a negative number
    test4:
        li   t0, 0x80000000
        srli t2, t0, 1
        li   t3, 0x40000000
        beq  t2, t3, test5
        j Fail_Srli_4

    # shift 31 bits
    test5:
        li   t0, 0x80000000
        srli t2, t0, 31
        li   t3, 0x1
        beq  t2, t3, pass_srli
        j Fail_Srli_5

pass_srli:
    j return_srli_test

Fail_Srli_1:
    li gp, 701
    j fail

Fail_Srli_2:
    li gp, 702
    j fail
Fail_Srli_3:
    li gp, 703
    j fail

Fail_Srli_4:
    li gp, 704
    j fail

Fail_Srli_5:
    li gp, 705
    j fail
