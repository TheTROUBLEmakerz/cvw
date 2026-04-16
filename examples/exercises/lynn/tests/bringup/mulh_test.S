.extern return_mulh_test
.extern fail

    .section .text.init
    .globl mulh_test
    .type  mulh_test, @function

mulh_test:
    test1:
        li   t0, 0xFFFF
        li   t1, 0xFFFF
        mulh t2, t0, t1
        li   t3, 0
        beq  t2, t3, test2
        j    Fail_Mulh_1
    test2:
        li   t0, 0x7FFFFFFF
        li   t1, 2
        mulh t2, t0, t1
        li   t3, 0
        beq  t2, t3, test3
        j    Fail_Mulh_2
    test3:
        li   t0, 0x7FFFFFFF
        li   t1, 0x7FFFFFFF
        mulh t2, t0, t1
        li   t3, 0x3FFFFFFF
        beq  t2, t3, test4
        j    Fail_Mulh_3
    test4:
        li   t0, -1
        li   t1, 1
        mulh t2, t0, t1
        li   t3, -1
        beq  t2, t3, test5
        j    Fail_Mulh_4
    test5:
        li   t0, -1
        li   t1, -1
        mulh t2, t0, t1
        li   t3, 0
        beq  t2, t3, test6
        j    Fail_Mulh_5
    test6:
        li   t0, 0x80000000
        li   t1, 2
        mulh t2, t0, t1
        li   t3, -1
        beq  t2, t3, test7
        j    Fail_Mulh_6
    test7:
        li   t0, 0x80000000
        li   t1, 0x80000000
        mulh t2, t0, t1
        li   t3, 0x40000000
        beq  t2, t3, test8
        j    Fail_Mulh_7
    test8:
        li   t0, -2
        li   t1, 0x40000000
        mulh t2, t0, t1
        li   t3, -1
        beq  t2, t3, test9
        j    Fail_Mulh_8
    test9:
        li   t0, 0x12345678
        li   t1, 0x12345678
        mulh t2, t0, t1
        li   t3, 0x014B66DC
        beq  t2, t3, test10
        j    Fail_Mulh_9
    test10:
        li   t0, -0x12345678
        li   t1, 0x12345678
        mulh t2, t0, t1
        li   t3, 0xFEB49923
        beq  t2, t3, pass
        j    Fail_Mulh_10

pass:
    j return_mulh_test

Fail_Mulh_1:  li gp, 4101; j fail
Fail_Mulh_2:  li gp, 4102; j fail
Fail_Mulh_3:  li gp, 4103; j fail
Fail_Mulh_4:  li gp, 4104; j fail
Fail_Mulh_5:  li gp, 4105; j fail
Fail_Mulh_6:  li gp, 4106; j fail
Fail_Mulh_7:  li gp, 4107; j fail
Fail_Mulh_8:  li gp, 4108; j fail
Fail_Mulh_9:  li gp, 4109; j fail
Fail_Mulh_10: li gp, 4110; j fail
