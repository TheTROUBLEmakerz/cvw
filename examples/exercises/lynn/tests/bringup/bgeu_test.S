.extern return_bgeu_test
.extern fail

    .section .text.init
    .globl bgeu_test
    .type  bgeu_test, @function

bgeu_test:
    test1:
        li   t0, 2
        li   t1, 1
        bgeu t0, t1, test2
        j Fail_Bgeu_1
    test2:
        li   t0, 1
        li   t1, 1
        bgeu t0, t1, test3
        j Fail_Bgeu_2
    test3:
        li   t0, 1
        li   t1, 2
        bgeu t0, t1, Fail_Bgeu_3
        j test4
    test4:
        li   t0, 0xFFFFFFFF
        li   t1, 0
        bgeu t0, t1, test5
        j Fail_Bgeu_4
    test5:
        li   t0, 0
        li   t1, 0xFFFFFFFF
        bgeu t0, t1, Fail_Bgeu_5
        j test6
    test6:
        li   t0, 0x80000000
        li   t1, 0x7FFFFFFF
        bgeu t0, t1, test7
        j Fail_Bgeu_6
    test7:
        li   t0, 0x7FFFFFFF
        li   t1, 0x80000000
        bgeu t0, t1, Fail_Bgeu_7
        j test8
    test8:
        li   t0, 1
        li   t1, 1
        bgeu t0, t1, test9
        j Fail_Bgeu_8
    test9:
        li   t0, 0x12345678
        li   t1, 0x12345678
        bgeu t0, t1, test10
        j Fail_Bgeu_9
    test10:
        li   t0, 0xFFFFFFFF
        li   t1, 0xFFFFFFFE
        bgeu t0, t1, pass
        j Fail_Bgeu_10

pass:
    j return_bgeu_test

Fail_Bgeu_1:
    li   gp, 3001
    j    fail
Fail_Bgeu_2:
    li   gp, 3002
    j    fail
Fail_Bgeu_3:
    li   gp, 3003
    j    fail
Fail_Bgeu_4:
    li   gp, 3004
    j    fail
Fail_Bgeu_5:
    li   gp, 3005
    j    fail
Fail_Bgeu_6:
    li   gp, 3006
    j    fail
Fail_Bgeu_7:
    li   gp, 3007
    j    fail
Fail_Bgeu_8:
    li   gp, 3008
    j    fail
Fail_Bgeu_9:
    li   gp, 3009
    j    fail
Fail_Bgeu_10:
    li   gp, 3010
    j    fail
