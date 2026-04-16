.extern return_sltiu_test
.extern fail

    .section .text.init
    .globl sltiu_test
    .type  sltiu_test, @function

sltiu_test:
    test1:
        li    t0, 5
        sltiu t2, t0, 10
        li    t3, 1
        beq   t2, t3, test2
        j Fail_Sltiu_1
    test2:
        li    t0, 0xFFFFFFFF
        sltiu t2, t0, 10
        li    t3, 0
        beq   t2, t3, test3
        j Fail_Sltiu_2
    test3:
        li    t0, 10
        sltiu t2, t0, 10
        li    t3, 0
        beq   t2, t3, test4
        j Fail_Sltiu_3
    test4:
        li    t0, 0
        sltiu t2, t0, 1
        li    t3, 1
        beq   t2, t3, test5
        j Fail_Sltiu_4
    test5:
        li    t0, 0x7FFFFFFF
        sltiu t2, t0, 0x7FF
        li    t3, 0
        beq   t2, t3, test6
        j Fail_Sltiu_5
    test6:
        li    t0, 11
        sltiu t2, t0, 10
        li    t3, 0
        beq   t2, t3, test7
        j Fail_Sltiu_6
    test7:
        li    t0, 0xFFFFFFFE
        sltiu t2, t0, 0x7FF
        li    t3, 0
        beq   t2, t3, test8
        j Fail_Sltiu_7
    test8:
        li    t0, 0
        sltiu t2, t0, 0
        li    t3, 0
        beq   t2, t3, test9
        j Fail_Sltiu_8
    test9:
        li    t0, 2047
        sltiu t2, t0, 2047
        li    t3, 0
        beq   t2, t3, test10
        j Fail_Sltiu_9
    test10:
        li    t0, 2046
        sltiu t2, t0, 2047
        li    t3, 1
        beq   t2, t3, pass
        j Fail_Sltiu_10

pass:
    j return_sltiu_test

Fail_Sltiu_1:
    li   gp, 1301
    j    fail
Fail_Sltiu_2:
    li   gp, 1302
    j    fail
Fail_Sltiu_3:
    li   gp, 1303
    j    fail
Fail_Sltiu_4:
    li   gp, 1304
    j    fail
Fail_Sltiu_5:
    li   gp, 1305
    j    fail
Fail_Sltiu_6:
    li   gp, 1306
    j    fail
Fail_Sltiu_7:
    li   gp, 1307
    j    fail
Fail_Sltiu_8:
    li   gp, 1308
    j    fail
Fail_Sltiu_9:
    li   gp, 1309
    j    fail
Fail_Sltiu_10:
    li   gp, 1310
    j    fail
