module AES_formal(
    input wire [127:0] data1,
    input wire [127:0] key1,

    input wire [127:0] data2,
    input wire [127:0] key2
);
/*
    input  wire [127:0] state,
    input  wire [127:0] round_key,
    output wire [127:0] out

*/
//  (data,key) -> Round -> invRound -> (data,key)
    wire [127:0] round_1;
    wire [127:0] round_inv_1;

    round       r1      (.state(data1), .round_key(key), .out(round_1));
    round_inv   r_inv_1 (.state(round_1), .round_key(key), .out(round_inv_1));

//  (data,key) -> invRound -> Round -> (data,key)
    wire [127:0] inv_2;
    wire [127:0] inv_round_2;

    round_inv   r_inv_2 (.state(data2), .round_key(key2), .out(inv_2));
    round       r_2     (.state(inv_2), .round_key(key2), .out(inv_round_2));


`ifdef FORMAL
    always @(*) begin
        assert(round_inv_1 == data1); //  (data,key) -> Round -> invRound -> (data,key)
        assert(inv_round_2 == data2); //  (data,key) -> invRound -> Round -> (data,key)
    end
`endif

endmodule