// This module generates the "random" sequences for the simon game.
// This module uses a perpetually running LFSR for seeding the sequence generator.
// If randomize is high this module will use the current LFSR value as the seed.
// Effectively this results in choosing a new random sequence.
// If start_over is high this module moves to the start of the random sequence.
// If next is high this module moves to the next element of the sequence.
// seq outputs the current element of the sequence using a one-hot encoding.
module sequence_generator (
	input clk,
	input randomize,
	input next,
	input start_over,
	output [3:0] seq
);
	reg [17:0] counter = 18'b100110101011010111;
	reg [17:0] seed;
	reg [17:0] current;
	
	assign seq = 4'b1 << current[1:0];
	
	always @(posedge clk) begin
		counter <= {counter[15:0], counter[17:16] ^ counter[10:9]};
		if (randomize)
			seed <= counter;
		if (start_over)
			current <= seed;
		else if (next)
			current <= {current[15:0], current[17:16] ^ current[10:9]};
	end
endmodule
