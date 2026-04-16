.extern return_mul_test
.extern fail

    .section .text.init
    .globl mul_test
    .type  mul_test, @function

mul_test:
    test1:
        li   t0, 10
        li   t1, 20
        mul  t2, t0, t1
        li   t3, 200
        beq  t2, t3, test2
        j    Fail_Mul_1
    test2:
        li   t0, -5
        li   t1, 4
        mul  t2, t0, t1
        li   t3, -20
        beq  t2, t3, test3
        j    Fail_Mul_2
    test3:
        li   t0, 0x80000000
        li   t1, 1
        mul  t2, t0, t1
        li   t3, 0x80000000
        beq  t2, t3, test4
        j    Fail_Mul_3
    test4:
        li   t0, 0x1000
        mul  t2, t0, t0
        li   t3, 0x01000000
        beq  t2, t3, test5
        j    Fail_Mul_4
    test5:
        li   t0, 0x10000
        mul  t2, t0, t0
        li   t3, 0
        beq  t2, t3, test6
        j    Fail_Mul_5
    test6:
        li   t0, 0xDEAD
        li   t1, 0xBEEF
        mul  t2, t0, t1
        li   t3, 0xA6144983
        beq  t2, t3, test7
        j    Fail_Mul_6
    test7:
        li   t0, 0x12345678
        li   t1, 0
        mul  t2, t0, t1
        li   t3, 0
        beq  t2, t3, test8
        j    Fail_Mul_7
    test8:
        li   t0, 0x55555555
        li   t1, -1
        mul  t2, t0, t1
        li   t3, 0xAAAAAAAB
        beq  t2, t3, test9
        j    Fail_Mul_8
    test9:
        li   t0, -2
        li   t1, -3
        mul  t2, t0, t1
        li   t3, 6
        beq  t2, t3, pass
        j    Fail_Mul_9
    test10:
        li   t0, 1000003
        li   t1, 1000033
        mul  t2, t0, t1
        li   t3, 0x36000099
        beq  t2, t3, pass
        j    Fail_Mul_10

pass:
    j return_mul_test

Fail_Mul_1:
    li gp, 4001
    j fail
Fail_Mul_2:
    li gp, 4002
    j fail
Fail_Mul_3:
    li gp, 4003
    j fail
Fail_Mul_4:
    li gp, 4004
    j fail
Fail_Mul_5:
    li gp, 4005
    j fail
Fail_Mul_6:
    li gp, 4006
    j fail
Fail_Mul_7:
    li gp, 4007
    j fail
Fail_Mul_8:
    li gp, 4008
    j fail
Fail_Mul_9:
    li gp, 4009
    j fail
Fail_Mul_10:
    li gp, 4010
    j fail
