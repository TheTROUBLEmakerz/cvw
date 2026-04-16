.extern return_mulhu_test
.extern fail

    .section .text.init
    .globl mulhu_test
    .type  mulhu_test, @function

mulhu_test:
    test_mhu1:
        li   t0, 0xFFFFFFFF
        li   t1, 0xFFFFFFFF
        mulhu t2, t0, t1
        li   t3, 0xFFFFFFFE
        beq  t2, t3, test_mhu2
        j    Fail_Mulhu_1
    test_mhu2:
        li   t0, 0x80000000
        li   t1, 0x80000000
        mulhu t2, t0, t1
        li   t3, 0x40000000
        beq  t2, t3, test_mhu3
        j    Fail_Mulhu_2
    test_mhu3:
        li   t0, 0x80000000
        li   t1, 2
        mulhu t2, t0, t1
        li   t3, 1
        beq  t2, t3, test_mhu4
        j    Fail_Mulhu_3
    test_mhu4:
        li   t0, 0x12345678
        li   t1, 0x87654321
        mulhu t2, t0, t1
        li   t3, 0x09A0CD05
        beq  t2, t3, test_mhu5
        j    Fail_Mulhu_4
    test_mhu5:
        li   t0, 0
        li   t1, 0xFFFFFFFF
        mulhu t2, t0, t1
        li   t3, 0
        beq  t2, t3, test_mhu6
        j    Fail_Mulhu_5
    test_mhu6:
        li   t0, 0xFFFFFFFF
        li   t1, 1
        mulhu t2, t0, t1
        li   t3, 0
        beq  t2, t3, test_mhu7
        j    Fail_Mulhu_6
    test_mhu7:
        li   t0, 0x40000000
        li   t1, 0x40000000
        mulhu t2, t0, t1
        li   t3, 0x10000000
        beq  t2, t3, test_mhu8
        j    Fail_Mulhu_7
    test_mhu8:
        li   t0, 0x2
        li   t1, 0xFFFFFFFF
        mulhu t2, t0, t1
        li   t3, 1
        beq  t2, t3, test_mhu9
        j    Fail_Mulhu_8
    test_mhu9:
        li   t0, 0x10000000
        li   t1, 0x10000000
        mulhu t2, t0, t1
        li   t3, 0x01000000
        beq  t2, t3, test_mhu10
        j    Fail_Mulhu_9
    test_mhu10:
        li   t0, 0xF0F0F0F0
        li   t1, 0x0F0F0F0F
        mulhu t2, t0, t1
        li   t3, 0x0E2C4A68
        beq  t2, t3, pass
        j    Fail_Mulhu_10

pass:
    j return_mulhu_test

Fail_Mulhu_1:  li gp, 4201; j fail
Fail_Mulhu_2:  li gp, 4202; j fail
Fail_Mulhu_3:  li gp, 4203; j fail
Fail_Mulhu_4:  li gp, 4204; j fail
Fail_Mulhu_5:  li gp, 4205; j fail
Fail_Mulhu_6:  li gp, 4206; j fail
Fail_Mulhu_7:  li gp, 4207; j fail
Fail_Mulhu_8:  li gp, 4208; j fail
Fail_Mulhu_9:  li gp, 4209; j fail
Fail_Mulhu_10: li gp, 4210; j fail
