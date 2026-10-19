// apb_pipeline_reg.sv — two-stage APB write pipeline
//
// An APB peripheral that pipelines write data through two stages before
// committing to the output register. Both stages are clocked.
//
// Pipeline:
//   Stage 1 (pipe1): captures pwdata on a valid APB write
//   Stage 2 (pipe2): captures pipe1 one cycle later
//   out_reg:         captures pipe2 one cycle after that
//
// write_en1/write_en2 are the per-stage valid bits flowing alongside the data.
// A credit counter tracks how many writes are in flight: +1 when one enters
// stage 1, -1 when one commits to out_reg.
//
// No bug. The design is correct. But mode prove fails at the inductive step
// until the right invariant is added.

module apb_pipeline_reg (
  input  logic        clk, rst,
  input  logic        psel, pwrite, penable,
  input  logic [7:0]  pwdata,
  output logic [7:0]  out_reg,
  output logic        data_valid
);
  logic [7:0] pipe1, pipe2;
  logic       write_en1, write_en2;
  logic [2:0] credits;   // in-flight writes currently in the pipeline

  wire do_write = psel && pwrite && penable;

  always_ff @(posedge clk) begin
    if (rst) begin
      pipe1      <= 0;
      pipe2      <= 0;
      out_reg    <= 0;
      write_en1  <= 0;
      write_en2  <= 0;
      credits    <= 0;
      data_valid <= 0;
    end else begin
      if (do_write) begin
        pipe1     <= pwdata;
        write_en1 <= 1;
      end else begin
        write_en1 <= 0;
      end
      pipe2     <= pipe1;
      write_en2 <= write_en1;
      if (write_en2) begin
        out_reg    <= pipe2;
        data_valid <= 1;
      end
      // credit accounting: +1 when a write enters stage 1, -1 when one commits
      credits <= credits + (do_write ? 3'd1 : 3'd0) - (write_en2 ? 3'd1 : 3'd0);
    end
  end

`ifdef FORMAL
  // 1. f_past_valid
  logic f_past_valid;
  initial f_past_valid = 0;
  always_ff @(posedge clk) f_past_valid <= 1;

  // 2. start od resetu
  initial assume(rst);

  always_ff @(posedge clk) begin
    if (f_past_valid) begin
      // 3. safety: pipeline ma 2 stopnie => max 2 zapisy w locie
      assert(credits <= 2);

      // 4. invariant: licznik zgodny z bitami valid
      assert(credits == {2'b00, write_en1} + {2'b00, write_en2});
    end
  end
`endif


endmodule