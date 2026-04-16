.extern return_mulhsu_test
.extern fail

    .section .text.init
    .globl mulhsu_test
    .type  mulhsu_test, @function

mulhsu_test:
    test_mhsu1:
        li   t0, 10
        li   t1, 10
        mulhsu t2, t0, t1
        li   t3, 0
        beq  t2, t3, test_mhsu2
        j    Fail_Mhsu_1
    test_mhsu2:
        li   t0, -1
        li   t1, 2
        mulhsu t2, t0, t1
        li   t3, -1
        beq  t2, t3, test_mhsu3
        j    Fail_Mhsu_2
    test_mhsu3:
        li   t0, -1
        li   t1, 0xFFFFFFFF
        mulhsu t2, t0, t1
        li   t3, -1
        beq  t2, t3, test_mhsu4
        j    Fail_Mhsu_3
    test_mhsu4:
        li   t0, 0x7FFFFFFF
        li   t1, 0xFFFFFFFF
        mulhsu t2, t0, t1
        li   t3, 0x7FFFFFFE
        beq  t2, t3, test_mhsu5
        j    Fail_Mhsu_4
    test_mhsu5:
        li   t0, 0x80000000
        li   t1, 2
        mulhsu t2, t0, t1
        li   t3, -1
        beq  t2, t3, test_mhsu6
        j    Fail_Mhsu_5
    test_mhsu6:
        li   t0, 0x80000000
        li   t1, 0xFFFFFFFF
        mulhsu t2, t0, t1
        li   t3, 0x80000000
        beq  t2, t3, test_mhsu7
        j    Fail_Mhsu_6
    test_mhsu7:
        li   t0, -2
        li   t1, 0x80000000
        mulhsu t2, t0, t1
        li   t3, -1
        beq  t2, t3, test_mhsu8
        j    Fail_Mhsu_7
    test_mhsu8:
        li   t0, 0x12345678
        li   t1, 0x87654321
        mulhsu t2, t0, t1
        li   t3, 0x09A0CD05
        beq  t2, t3, test_mhsu10
        j    Fail_Mhsu_8
    test_mhsu9:
        li   t0, -0x12345678
        li   t1, 0x87654321
        mulhsu t2, t0, t1
        li   t3, 0x7DC4761B
        beq  t2, t3, test_mhsu10
        j    Fail_Mhsu_9
    test_mhsu10:
        li   t0, 0x70707070
        li   t1, 0x0F0F0F0F
        mulhsu t2, t0, t1
        li   t3, 0x069D33CA
        beq  t2, t3, pass
        j    Fail_Mhsu_10

pass:
    j return_mulhsu_test

Fail_Mhsu_1:  li gp, 4301; j fail
Fail_Mhsu_2:  li gp, 4302; j fail
Fail_Mhsu_3:  li gp, 4303; j fail
Fail_Mhsu_4:  li gp, 4304; j fail
Fail_Mhsu_5:  li gp, 4305; j fail
Fail_Mhsu_6:  li gp, 4306; j fail
Fail_Mhsu_7:  li gp, 4307; j fail
Fail_Mhsu_8:  li gp, 4308; j fail
Fail_Mhsu_9:  li gp, 4309; j fail
Fail_Mhsu_10: li gp, 4310; j fail
