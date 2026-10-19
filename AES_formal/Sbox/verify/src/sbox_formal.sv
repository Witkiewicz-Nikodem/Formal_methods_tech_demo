module sbox_formal (
    input wire [7:0] in
);
    wire [7:0] out_ref;
    wire [7:0] out_tab;
    wire [7:0] out_tab_inv_tab;

    sbox_ref a (.in(in), .out(out_ref));
    sbox_tab b (.in(in), .out(out_tab));

    invsbox_tab c (.in(out_tab), .out(out_tab_inv_tab));

`ifdef FORMAL
    always @(*) begin
        assert(out_ref == out_tab);
        assert(in == out_tab_inv_tab);
    end
`endif
endmodule