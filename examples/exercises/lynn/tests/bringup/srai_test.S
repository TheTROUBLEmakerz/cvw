.extern return_srai_test
.extern fail

    .section .text.init
    .globl srai_test
    .type  srai_test, @function

srai_test:
    test1:
        li   t0, 0x40
        srai t2, t0, 2
        li   t3, 0x10
        beq  t2, t3, test2
        j Fail_Srai_1
    test2:
        li   t0, 0x80000000
        srai t2, t0, 1
        li   t3, 0xC0000000
        beq  t2, t3, test3
        j Fail_Srai_2
    test3:
        li   t0, 0xFFFFFFF0
        srai t2, t0, 4
        li   t3, 0xFFFFFFFF
        beq  t2, t3, test4
        j Fail_Srai_3
    test4:
        li   t0, 0x40000000
        srai t2, t0, 31
        li   t3, 0
        beq  t2, t3, test5
        j Fail_Srai_4
    test5:
        li   t0, 0xFFFFFFFF
        srai t2, t0, 31
        li   t3, 0xFFFFFFFF
        beq  t2, t3, test6
        j Fail_Srai_5
    test6:
        li   t0, 0x1
        srai t2, t0, 1
        li   t3, 0
        beq  t2, t3, test7
        j Fail_Srai_6
    test7:
        li   t0, 0xFFFF0000
        srai t2, t0, 16
        li   t3, 0xFFFFFFFF
        beq  t2, t3, test8
        j Fail_Srai_7
    test8:
        li   t0, 0x0
        srai t2, t0, 5
        li   t3, 0
        beq  t2, t3, test9
        j Fail_Srai_8
    test9:
        li   t0, 0x7FFFFFFF
        srai t2, t0, 30
        li   t3, 0x1
        beq  t2, t3, test10
        j Fail_Srai_9
    test10:
        li   t0, 0x80000001
        srai t2, t0, 31
        li   t3, 0xFFFFFFFF
        beq  t2, t3, pass_srai
        j Fail_Srai_10

pass_srai:
    j return_srai_test

Fail_Srai_1:
    li   gp, 1101
    j    fail
Fail_Srai_2:
    li   gp, 1102
    j    fail
Fail_Srai_3:
    li   gp, 1103
    j    fail
Fail_Srai_4:
    li   gp, 1104
    j    fail
Fail_Srai_5:
    li   gp, 1105
    j    fail
Fail_Srai_6:
    li   gp, 1106
    j    fail
Fail_Srai_7:
    li   gp, 1107
    j    fail
Fail_Srai_8:
    li   gp, 1108
    j    fail
Fail_Srai_9:
    li   gp, 1109
    j    fail
Fail_Srai_10:
    li   gp, 1110
    j    fail
