module round_inv (
    input  wire [127:0] state,
    input  wire [127:0] round_key,
    output wire [127:0] out
);
    wire [127:0] keyed, unmixed, unshifted;

    add_key u_ark (.state(state), .key(round_key), .out(keyed));

    // InvMixColumns: 4 x invmixcol (kolumna 0 = [127:96])
    for (genvar c = 0; c < 4; c++) begin : g_mix
        invmixcol u (.in(keyed[127-32*c -: 32]), .out(unmixed[127-32*c -: 32]));
    end

    shift_rows_tab_inv u_isr (.in(unmixed), .out(unshifted));

    // InvSubBytes: 16 x invsbox_tab
    for (genvar i = 0; i < 16; i++) begin : g_sub
        invsbox_tab u (.in(unshifted[127-8*i -: 8]), .out(out[127-8*i -: 8]));
    end
endmodule