module shift_rows_formal (
    input wire [127:0] in
);
    wire [127:0] out_ref;
    wire [127:0] out_tab;
    wire [127:0] out_tab_inv;

    shift_rows_ref a (.in(in), .out(out_ref));
    shift_rows_tab b (.in(in), .out(out_tab));

    shift_rows_tab_inv c (.in(out_tab), .out(out_tab_inv));

`ifdef FORMAL
    always @(*) begin
        assert(out_ref == out_tab);
        assert(in == out_tab_inv);
    end
`endif
endmodule