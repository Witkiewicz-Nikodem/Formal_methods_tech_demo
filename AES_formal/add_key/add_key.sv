module add_key (
    input  wire [127:0] state,
    input  wire [127:0] key,
    output wire [127:0] out
);
    assign out = state ^ key;
endmodule