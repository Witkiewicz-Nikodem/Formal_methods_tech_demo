module shift_rows_ref (
    input  wire [127:0] in,
    output wire [127:0] out
);
    genvar r, c;
    generate
        for (c = 0; c < 4; c = c + 1) begin : g_col
            for (r = 0; r < 4; r = r + 1) begin : g_row
                localparam integer DST = r + 4 * c;
                localparam integer SRC = r + 4 * ((c + r) % 4);
                assign out[127 - 8*DST -: 8] = in[127 - 8*SRC -: 8];
            end
        end
    endgenerate
endmodule
