.extern return_bltu_test
.extern fail

    .section .text.init
    .globl bltu_test
    .type  bltu_test, @function

bltu_test:
    test1:
        li   t0, 1
        li   t1, 2
        bltu t0, t1, test2
        j Fail_Bltu_1
    test2:
        li   t0, 2
        li   t1, 1
        bltu t0, t1, Fail_Bltu_2
        j test3
    test3:
        li   t0, 0xFFFFFFFF
        li   t1, 1
        bltu t0, t1, Fail_Bltu_3
        j test4
    test4:
        li   t0, 1
        li   t1, 0xFFFFFFFF
        bltu t0, t1, test5
        j Fail_Bltu_4
    test5:
        li   t0, 0
        li   t1, 0
        bltu t0, t1, Fail_Bltu_5
        j test6
    test6:
        li   t0, 0
        li   t1, 1
        bltu t0, t1, test7
        j Fail_Bltu_6
    test7:
        li   t0, 0x80000000
        li   t1, 0x80000001
        bltu t0, t1, test8
        j Fail_Bltu_7
    test8:
        li   t0, 0x80000001
        li   t1, 0x80000000
        bltu t0, t1, Fail_Bltu_8
        j test9
    test9:
        li   t0, 0x7FFFFFFF
        li   t1, 0x80000000
        bltu t0, t1, test10
        j Fail_Bltu_9
    test10:
        li   t0, 0xFFFFFFFE
        li   t1, 0xFFFFFFFF
        bltu t0, t1, pass
        j Fail_Bltu_10

pass:
    j return_bltu_test

Fail_Bltu_1:
    li   gp, 2801
    j    fail
Fail_Bltu_2:
    li   gp, 2802
    j    fail
Fail_Bltu_3:
    li   gp, 2803
    j    fail
Fail_Bltu_4:
    li   gp, 2804
    j    fail
Fail_Bltu_5:
    li   gp, 2805
    j    fail
Fail_Bltu_6:
    li   gp, 2806
    j    fail
Fail_Bltu_7:
    li   gp, 2807
    j    fail
Fail_Bltu_8:
    li   gp, 2808
    j    fail
Fail_Bltu_9:
    li   gp, 2809
    j    fail
Fail_Bltu_10:
    li   gp, 2810
    j    fail
