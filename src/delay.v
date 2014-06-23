// This module is used for creating delays
// reset will reset this module
// fast pulse will go high for one clock cycle 0.2 seconds after a reset
// slow pulse will go high for one clock cycle 0.75 seconds after a reset
// NOTE: Every time this module is reset the time before getting will also
//       be reset. So if reset is constantly held high you will never get
//       either pulse.
module delay (
	input clk,
	input reset,
	input [3:0] variable_pulse_index,
	output slow_pulse,
	output fast_pulse,
	output variable_pulse
);
	reg [31:0] counter;
	wire [31:0] variable_pulse_num;
	
	assign variable_pulse_num = 32'd24000000 - (32'd2000000 * variable_pulse_index);
	
	assign slow_pulse = (counter == 31'd18000000); //18mil
	assign fast_pulse = (counter == 31'd4800000);  //4.8mil
	assign variable_pulse = (counter == variable_pulse_num);
	
	initial begin
		counter <= 32'd0;
	end
	
	always @(posedge clk) begin
//		if (reset)
//			counter <= 32'd0;
//		else
//			counter <= counter + 1'b1;
	end
endmodule
