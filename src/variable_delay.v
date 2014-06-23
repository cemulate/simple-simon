// This module is used for creating delays
// reset will reset this module
// fast pulse will go high for one clock cycle 0.2 seconds after a reset
// slow pulse will go high for one clock cycle 0.75 seconds after a reset
// NOTE: Every time this module is reset the time before getting will also
//       be reset. So if reset is constantly held high you will never get
//       either pulse.
module variable_delay (
	input clk,
	input reset,
	input [4:0] variable_pulse_index,
	output variable_pulse
);
	reg [31:0] counter = 32'd0;
	reg [31:0] variable_pulse_num;
	
	//assign variable_pulse_num = 32'd24000000 - (32'd2000000 * variable_pulse_index);
	
	assign variable_pulse = (counter == variable_pulse_num);
	
	initial begin
		counter <= 32'd0;
		//variable_pulse_num <= 32'd10;
		variable_pulse_num <= 32'd32000000;
	end
	
	always @ (negedge clk) begin
		
		if (reset)
			counter <= 32'd0;
		else
			counter <= counter + 32'd1;
		
	end
	
	always @ (posedge clk) begin
		case (variable_pulse_index)
			5'b00000: variable_pulse_num <= 32'd32000000;
			5'b00001: variable_pulse_num <= 32'd31000000;
			5'b00010: variable_pulse_num <= 32'd30000000;
			5'b00011: variable_pulse_num <= 32'd29000000;
			5'b00100: variable_pulse_num <= 32'd28000000;
			5'b00101: variable_pulse_num <= 32'd27000000;
			5'b00110: variable_pulse_num <= 32'd26000000;
			5'b00111: variable_pulse_num <= 32'd25000000;
			5'b01000: variable_pulse_num <= 32'd24000000;
			5'b01001: variable_pulse_num <= 32'd23000000;
			5'b01010: variable_pulse_num <= 32'd22000000;
			5'b01011: variable_pulse_num <= 32'd21000000;
			5'b01100: variable_pulse_num <= 32'd20000000;
			5'b01101: variable_pulse_num <= 32'd19000000;
			5'b01110: variable_pulse_num <= 32'd18000000;
			5'b01111: variable_pulse_num <= 32'd17000000;
			5'b10000: variable_pulse_num <= 32'd16000000;
			5'b10001: variable_pulse_num <= 32'd15000000;
			5'b10010: variable_pulse_num <= 32'd14000000;
			5'b10011: variable_pulse_num <= 32'd13000000;
			5'b10100: variable_pulse_num <= 32'd12000000;
			5'b10101: variable_pulse_num <= 32'd11000000;
			5'b10110: variable_pulse_num <= 32'd10000000;
			5'b10111: variable_pulse_num <= 32'd9000000;
			5'b11000: variable_pulse_num <= 32'd8000000;
			5'b11001: variable_pulse_num <= 32'd7000000;
			5'b11010: variable_pulse_num <= 32'd6000000;
			5'b11011: variable_pulse_num <= 32'd5000000;
			5'b11100: variable_pulse_num <= 32'd4000000;
			5'b11101: variable_pulse_num <= 32'd3000000;
			5'b11110: variable_pulse_num <= 32'd2000000;
			5'b11111: variable_pulse_num <= 32'd1000000;
		endcase
		
//		if (reset)
//			counter <= 32'd0;
//		
//		counter <= counter + 32'd1;
	end
endmodule
