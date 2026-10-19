module sbox_ref (
    input  wire [7:0] in,
    output wire [7:0] out
);
 
    // Mnozenie przez x w GF(2^8)
    function [7:0] xtime;
        input [7:0] a;
        begin
            xtime = {a[6:0], 1'b0} ^ (a[7] ? 8'h1b : 8'h00);
        end
    endfunction
 
    // Mnozenie dwoch elementow GF(2^8) (shift-and-add)
    function [7:0] gmul;
        input [7:0] a;
        input [7:0] b;
        integer k;
        reg [7:0] p, t;
        begin
            p = 8'h00;
            t = a;
            for (k = 0; k < 8; k = k + 1) begin
                if (b[k]) p = p ^ t;
                t = xtime(t);
            end
            gmul = p;
        end
    endfunction
 
    // Odwrotnosc: x^254 = x^2 * x^4 * x^8 * ... * x^128
    function [7:0] ginv;
        input [7:0] x;
        integer k;
        reg [7:0] pw, acc;
        begin
            pw  = x;
            acc = 8'h01;
            for (k = 1; k < 8; k = k + 1) begin
                pw  = gmul(pw, pw);    // x^(2^k)
                acc = gmul(acc, pw);   // iloczyn kolejnych kwadratow
            end
            ginv = acc;                // dla x = 0 daje 0
        end
    endfunction
 
    // Przeksztalcenie afiniczne nad GF(2)
    function [7:0] affine;
        input [7:0] b;
        begin
            affine = b ^ {b[6:0], b[7]} ^ {b[5:0], b[7:6]}
                       ^ {b[4:0], b[7:5]} ^ {b[3:0], b[7:4]} ^ 8'h63;
        end
    endfunction
 
    wire [7:0] inv;
    wire [7:0] aff;
    
    assign inv = ginv(in);
    assign aff = affine(inv);
    
    assign out = aff; 


endmodule