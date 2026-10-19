module sbox_formal (
    input wire [127:0] in_data,
    input wire [127:0] in_key
);
    wire [127:0] key_add;
    wire [127:0] key_double_add;

    add_key add1 (.state(in_data), .key(in_key), .out(key_add));
    add_key add2 (.state(key_add), .key(in_key), .out(key_double_add));

`ifdef FORMAL
    always @(*) begin
        assert(in_data == key_double_add);
    end
`endif
endmodule