.extern return_lhu_test
.extern fail

    .section .text.init
    .globl lhu_test
    .type  lhu_test, @function

lhu_test:
    li sp, 0x80000F00
    addi t1, sp, -4

    test1:
        li   t0, 0x8000
        sh   t0, 0(t1)
        lhu  t2, 0(t1)
        li   t3, 32768
        beq  t2, t3, test2
        j Fail_Lhu_1
    test2:
        li   t0, 0xFFFF
        sh   t0, 0(t1)
        lhu  t2, 0(t1)
        li   t3, 65535
        beq  t2, t3, test3
        j Fail_Lhu_2
    test3:
        li   t0, 0x7FFF
        sh   t0, 0(t1)
        lhu  t2, 0(t1)
        li   t3, 32767
        beq  t2, t3, test4
        j Fail_Lhu_3
    test4:
        li   t0, 0x0000
        sh   t0, 0(t1)
        lhu  t2, 0(t1)
        li   t3, 0
        beq  t2, t3, test5
        j Fail_Lhu_4
    test5:
        li   t0, 0x0001
        sh   t0, 0(t1)
        lhu  t2, 0(t1)
        li   t3, 1
        beq  t2, t3, test6
        j Fail_Lhu_5
    test6:
        li   t0, 0xFFFE
        sh   t0, 0(t1)
        lhu  t2, 0(t1)
        li   t3, 65534
        beq  t2, t3, test7
        j Fail_Lhu_6
    test7:
        li   t0, 0x1234
        sh   t0, 0(t1)
        lhu  t2, 0(t1)
        li   t3, 0x1234
        beq  t2, t3, test8
        j Fail_Lhu_7
    test8:
        li   t0, 0x8001
        sh   t0, 0(t1)
        lhu  t2, 0(t1)
        li   t3, 32769
        beq  t2, t3, test9
        j Fail_Lhu_8
    test9:
        li   t0, 0xAAAA
        sh   t0, 0(t1)
        lhu  t2, 0(t1)
        li   t3, 43690
        beq  t2, t3, test10
        j Fail_Lhu_9
    test10:
        li   t0, 0x5555
        sh   t0, 0(t1)
        lhu  t2, 0(t1)
        li   t3, 21845
        beq  t2, t3, pass_lhu
        j Fail_Lhu_10

pass_lhu:
    addi sp, sp, 4
    j return_lhu_test

Fail_Lhu_1:
    li   gp, 2301
    j    fail
Fail_Lhu_2:
    li   gp, 2302
    j    fail
Fail_Lhu_3:
    li   gp, 2303
    j    fail
Fail_Lhu_4:
    li   gp, 2304
    j    fail
Fail_Lhu_5:
    li   gp, 2305
    j    fail
Fail_Lhu_6:
    li   gp, 2306
    j    fail
Fail_Lhu_7:
    li   gp, 2307
    j    fail
Fail_Lhu_8:
    li   gp, 2308
    j    fail
Fail_Lhu_9:
    li   gp, 2309
    j    fail
Fail_Lhu_10:
    li   gp, 2310
    j    fail
