module mix_column_formal (
    input wire [31:0] in1,
    input wire [31:0] in2
);
    // mixcol_ref
    wire [31:0] mixed_ref;
    mixcol_ref mixalg (.in(in1),  .out(mixed_ref));

    wire [31:0] mixed, mixed_inv;   // in -> Mix -> Inv
    mixcol    mix1 (.in(in1),    .out(mixed));
    invmixcol inv1 (.in(mixed), .out(mixed_inv));

    wire [31:0] inv, inv_mixed;      // in -> Inv -> Mix
    invmixcol inv2 (.in(in2),  .out(inv));
    mixcol    mix2 (.in(inv), .out(inv_mixed));

`ifdef FORMAL
    always @(*) begin
        assert(mixed_inv == in1); // in -> Mix -> Inv 
        assert(inv_mixed == in2);// in -> Inv -> Mix
        assert(mixed_ref == mixed);
    end
`endif
endmodule