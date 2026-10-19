module invmixcol (
    input  wire [31:0] in,
    output wire [31:0] out
);
    wire [7:0] a0 = in[31:24];
    wire [7:0] a1 = in[23:16];
    wire [7:0] a2 = in[15:8];
    wire [7:0] a3 = in[7:0];

    // krok wstepny: u = 4*(a0^a2), v = 4*(a1^a3)
    wire [7:0] d02 = a0 ^ a2;
    wire [7:0] d13 = a1 ^ a3;

    wire [7:0] d02x2 = {d02[6], d02[5], d02[4], d02[3]^d02[7], d02[2]^d02[7], d02[1], d02[0]^d02[7], d02[7]};
    wire [7:0] d13x2 = {d13[6], d13[5], d13[4], d13[3]^d13[7], d13[2]^d13[7], d13[1], d13[0]^d13[7], d13[7]};

    wire [7:0] u = {d02x2[6], d02x2[5], d02x2[4], d02x2[3]^d02x2[7], d02x2[2]^d02x2[7], d02x2[1], d02x2[0]^d02x2[7], d02x2[7]};
    wire [7:0] v = {d13x2[6], d13x2[5], d13x2[4], d13x2[3]^d13x2[7], d13x2[2]^d13x2[7], d13x2[1], d13x2[0]^d13x2[7], d13x2[7]};

    wire [7:0] p0 = a0 ^ u;
    wire [7:0] p1 = a1 ^ v;
    wire [7:0] p2 = a2 ^ u;
    wire [7:0] p3 = a3 ^ v;

    // dalej zwykle MixColumns na p0..p3
    wire [7:0] p0x2 = {p0[6], p0[5], p0[4], p0[3]^p0[7], p0[2]^p0[7], p0[1], p0[0]^p0[7], p0[7]};
    wire [7:0] p1x2 = {p1[6], p1[5], p1[4], p1[3]^p1[7], p1[2]^p1[7], p1[1], p1[0]^p1[7], p1[7]};
    wire [7:0] p2x2 = {p2[6], p2[5], p2[4], p2[3]^p2[7], p2[2]^p2[7], p2[1], p2[0]^p2[7], p2[7]};
    wire [7:0] p3x2 = {p3[6], p3[5], p3[4], p3[3]^p3[7], p3[2]^p3[7], p3[1], p3[0]^p3[7], p3[7]};

    assign out[31:24] = p0x2 ^ p1x2 ^ p1 ^ p2 ^ p3;   // 2 3 1 1
    assign out[23:16] = p0 ^ p1x2 ^ p2x2 ^ p2 ^ p3;   // 1 2 3 1
    assign out[15:8]  = p0 ^ p1 ^ p2x2 ^ p3x2 ^ p3;   // 1 1 2 3
    assign out[7:0]   = p0x2 ^ p0 ^ p1 ^ p2 ^ p3x2;   // 3 1 1 2
endmodule