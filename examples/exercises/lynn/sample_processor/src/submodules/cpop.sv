module cpop(
    input logic[31:0] A,
    output logic[31:0] OnesCount
    );

    logic [5:0] sum;

    always_comb begin
        sum = '0;
        for (int i=0; i<32; i++) begin : count
            sum = (A[i]) ? sum+1 : sum;
        end
    end

    assign OnesCount = {26'b0, sum};

endmodule
