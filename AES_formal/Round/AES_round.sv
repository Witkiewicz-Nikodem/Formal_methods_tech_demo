module round (
    input  wire [127:0] state,
    input  wire [127:0] round_key,
    output wire [127:0] out
);
    wire [127:0] sub, shifted, mixed;

    // SubBytes: 16 x sbox_tab (bajt 0 = [127:120])
    for (genvar i = 0; i < 16; i++) begin : g_sub
        sbox_tab u (.in(state[127-8*i -: 8]), .out(sub[127-8*i -: 8]));
    end

    shift_rows_tab u_sr (.in(sub), .out(shifted));

    // MixColumns: 4 x mixcol (kolumna 0 = [127:96])
    for (genvar c = 0; c < 4; c++) begin : g_mix
        mixcol u (.in(shifted[127-32*c -: 32]), .out(mixed[127-32*c -: 32]));
    end

    add_key u_ark (.state(mixed), .key(round_key), .out(out));
endmodule