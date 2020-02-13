/*=============================================================================
 * Title        : Fizz Buzz generator testbench
 *
 * File Name    : TB_FIZZ_BUZZ.sv
 * Project      : Sample
 * Block        : 
 * Tree         : 
 * Designer     : toms74209200 <https://github.com/toms74209200>
 * Created      : 2020/02/13
 * License      : MIT License.
                  http://opensource.org/licenses/mit-license.php
 *============================================================================*/

`timescale 1ns/1ns

`define Comment(sentence) \
$display("%0s(%0d) %0s.", `__FILE__, `__LINE__, sentence)
`define MessageOK(name, value) \
$display("%0s(%0d) OK:Assertion %0s = %h.", `__FILE__, `__LINE__, name, value)
`define MessageERROR(name, variable, value) \
$error("%0s(%0d) ERROR:Assertion %0s /= %h failed. %0s = %h", `__FILE__, `__LINE__, name, value, name, variable)
`define ChkValue(name, variable, value) \
    if ((variable)===(value)) \
        `MessageOK(name, value); \
    else \
        `MessageERROR(name, variable, value);

module TB_FIZZ_BUZZ ;

// Simulation module signal
bit         RESET_n;            //(n) Reset
bit         CLK;                //(p) Clock
bit         SINK_READY;         //(p) Sink data ready
bit         SINK_VALID;         //(p) Sink data valid
bit [31:0]  SINK_DATA;          //(p) Sink data(Max Fizz Buzz count)
bit         SOURCE_VALID;       //(p) Source data valid
bit [31:0]  SOURCE_DATA;        //(p) Source data
bit [2:0]   SOURCE_FIZZBUZZ;    //(p) Source Fizz Buzz selector(2:FizzBuzz,1:Buzz,0:Fizz)

// Parameter
parameter ClkCyc    = 10;       // Signal change interval(10ns/50MHz)
parameter ResetTime = 20;       // Reset hold time

// DUT
FIZZ_BUZZ U_FIZZ_BUZZ(
.RESET_n(RESET_n),
.CLK(CLK),
.SINK_READY(SINK_READY),
.SINK_VALID(SINK_VALID),
.SINK_DATA(SINK_DATA),
.SOURCE_VALID(SOURCE_VALID),
.SOURCE_DATA(SOURCE_DATA),
.SOURCE_FIZZBUZZ(SOURCE_FIZZBUZZ)
);

/*=============================================================================
 * Clock
 *============================================================================*/
always begin
    #(ClkCyc);
    CLK = ~CLK;
end


/*=============================================================================
 * Reset
 *============================================================================*/
initial begin
    #(ResetTime);
    RESET_n = 1;
end 

/*=============================================================================
 * Fizz Buzz
 *============================================================================*/
initial begin
    #(ResetTime);
    @(posedge CLK);
    
    wait(SINK_READY);
    SINK_VALID = 1'b1;
    SINK_DATA = 32'd100;
    @(posedge CLK);
    SINK_VALID = 1'b0;

    wait(SOURCE_VALID);
    @(posedge CLK);
    repeat(100) begin
        if (SOURCE_FIZZBUZZ == 3'b100)
            $display("FizzBuzz");
        else if (SOURCE_FIZZBUZZ == 3'b010)
            $display("Buzz");
        else if (SOURCE_FIZZBUZZ == 3'b001)
            $display("Fizz");
        else
            $display("%0d",SOURCE_DATA);
        @(posedge CLK);
    end

    $finish;
end

endmodule
// TB_FIZZ_BUZZ
