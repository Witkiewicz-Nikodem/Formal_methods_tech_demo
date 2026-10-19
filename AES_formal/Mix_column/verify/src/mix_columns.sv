
module mixcol (
    input  wire [31:0] in,
    output wire [31:0] out
);
    wire [7:0] a0 = in[31:24];
    wire [7:0] a1 = in[23:16];
    wire [7:0] a2 = in[15:8];
    wire [7:0] a3 = in[7:0];

    // 2*a: przesuniecie + XOR bitu 7
    wire [7:0] a0x2 = {a0[6], a0[5], a0[4], a0[3]^a0[7], a0[2]^a0[7], a0[1], a0[0]^a0[7], a0[7]};
    wire [7:0] a1x2 = {a1[6], a1[5], a1[4], a1[3]^a1[7], a1[2]^a1[7], a1[1], a1[0]^a1[7], a1[7]};
    wire [7:0] a2x2 = {a2[6], a2[5], a2[4], a2[3]^a2[7], a2[2]^a2[7], a2[1], a2[0]^a2[7], a2[7]};
    wire [7:0] a3x2 = {a3[6], a3[5], a3[4], a3[3]^a3[7], a3[2]^a3[7], a3[1], a3[0]^a3[7], a3[7]};

    // 3*a = 2*a ^ a
    assign out[31:24] = a0x2 ^ a1x2 ^ a1 ^ a2 ^ a3;   // 2 3 1 1
    assign out[23:16] = a0 ^ a1x2 ^ a2x2 ^ a2 ^ a3;   // 1 2 3 1
    assign out[15:8]  = a0 ^ a1 ^ a2x2 ^ a3x2 ^ a3;   // 1 1 2 3
    assign out[7:0]   = a0x2 ^ a0 ^ a1 ^ a2 ^ a3x2;   // 3 1 1 2
endmodule