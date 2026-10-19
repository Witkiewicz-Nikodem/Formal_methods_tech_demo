module mixcol_ref #(
    parameter INV = 0              // 0 = MixColumns, 1 = InvMixColumns
)(
    input  wire [127:0] in,  // bajt 0 = bity [127:120], kolumna 0 = [127:96]
    output reg  [127:0] out
);

    // mnożenie przez x (czyli przez 2) w GF(2^8), wielomian 0x11B
    function [7:0] xtime(input [7:0] a);
        begin
            xtime = {a[6:0], 1'b0} ^ (a[7] ? 8'h1B : 8'h00);
        end
    endfunction

    // ogólne mnożenie w GF(2^8); dla stałego b synteza rozwija pętlę do XOR-ów
    function [7:0] gmul(input [7:0] a, input [7:0] b);
        integer i;
        reg [7:0] aa, bb, r;
        begin
            aa = a; bb = b; r = 8'h00;
            for (i = 0; i < 8; i = i + 1) begin
                if (bb[0]) r = r ^ aa;   // dodawanie = XOR
                aa = xtime(aa);          // a := a * x
                bb = bb >> 1;
            end
            gmul = r;
        end
    endfunction

    // macierze są cykliczne: M[i][j] = pierwszy_wiersz[(j - i) mod 4]
    function [7:0] coef(input [1:0] k);
        begin
            if (INV == 0)
                case (k)                 // wiersz: 2 3 1 1
                    2'd0: coef = 8'd2;
                    2'd1: coef = 8'd3;
                    2'd2: coef = 8'd1;
                    default: coef = 8'd1;
                endcase
            else
                case (k)                 // wiersz: 14 11 13 9
                    2'd0: coef = 8'd14;
                    2'd1: coef = 8'd11;
                    2'd2: coef = 8'd13;
                    default: coef = 8'd9;
                endcase
        end
    endfunction

    integer c, i, j;
    reg [7:0] acc;

    always @* begin
        out = 128'b0;
        for (c = 0; c < 4; c = c + 1) begin          // kolumny
            for (i = 0; i < 4; i = i + 1) begin      // wiersz wyniku
                acc = 8'h00;
                for (j = 0; j < 4; j = j + 1)        // iloczyn wiersz × kolumna
                    acc = acc ^ gmul(coef((j - i + 4) % 4),
                                     in[127 - 32*c - 8*j -: 8]);
                out[127 - 32*c - 8*i -: 8] = acc;
            end
        end
    end

endmodule