.extern return_lbu_test
.extern fail

    .section .text.init
    .globl lbu_test
    .type  lbu_test, @function

lbu_test:
    # Setup: Use stack space to store test values
    li sp, 0x80000F00
    addi t1, sp, -4

    test1:
        li   t0, 0x80
        sb   t0, 0(t1)
        lbu  t2, 0(t1)
        li   t3, 128
        beq  t2, t3, test2
        j Fail_Lbu_1
    test2:
        li   t0, 0xFF
        sb   t0, 0(t1)
        lbu  t2, 0(t1)
        li   t3, 255
        beq  t2, t3, test3
        j Fail_Lbu_2
    test3:
        li   t0, 0x7F
        sb   t0, 0(t1)
        lbu  t2, 0(t1)
        li   t3, 127
        beq  t2, t3, test4
        j Fail_Lbu_3
    test4:
        li   t0, 0x00
        sb   t0, 0(t1)
        lbu  t2, 0(t1)
        li   t3, 0
        beq  t2, t3, test5
        j Fail_Lbu_4
    test5:
        li   t0, 0x01
        sb   t0, 0(t1)
        lbu  t2, 0(t1)
        li   t3, 1
        beq  t2, t3, test6
        j Fail_Lbu_5
    test6:
        li   t0, 0xFE
        sb   t0, 0(t1)
        lbu  t2, 0(t1)
        li   t3, 254
        beq  t2, t3, test7
        j Fail_Lbu_6
    test7:
        li   t0, 0x42
        sb   t0, 0(t1)
        lbu  t2, 0(t1)
        li   t3, 66
        beq  t2, t3, test8
        j Fail_Lbu_7
    test8:
        li   t0, 0x81
        sb   t0, 0(t1)
        lbu  t2, 0(t1)
        li   t3, 129
        beq  t2, t3, test9
        j Fail_Lbu_8
    test9:
        li   t0, 0xAA
        sb   t0, 0(t1)
        lbu  t2, 0(t1)
        li   t3, 170
        beq  t2, t3, test10
        j Fail_Lbu_9
    test10:
        li   t0, 0x55
        sb   t0, 0(t1)
        lbu  t2, 0(t1)
        li   t3, 85
        beq  t2, t3, pass
        j Fail_Lbu_10

pass:
    addi sp, sp, 4
    j return_lbu_test

Fail_Lbu_1:
    li   gp, 2101
    j    fail
Fail_Lbu_2:
    li   gp, 2102
    j    fail
Fail_Lbu_3:
    li   gp, 2103
    j    fail
Fail_Lbu_4:
    li   gp, 2104
    j    fail
Fail_Lbu_5:
    li   gp, 2105
    j    fail
Fail_Lbu_6:
    li   gp, 2106
    j    fail
Fail_Lbu_7:
    li   gp, 2107
    j    fail
Fail_Lbu_8:
    li   gp, 2108
    j    fail
Fail_Lbu_9:
    li   gp, 2109
    j    fail
Fail_Lbu_10:
    li   gp, 2110
    j    fail
