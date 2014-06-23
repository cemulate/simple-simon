module testbench_round_win_anim();
  
  logic clk, next, reset;
  logic [3:0] sound;
  logic light1, light2, light3, light4;
  
  round_win_anim dut(.clk, .reset, .next, .sound, .light1, .light2, .light3, .light4);
  
  always begin
    clk = 0; #5; clk = 1; #5;
  end
  
  always begin
    
    #40;
    
    reset = 1;
	next = 0;
	#5;
	reset = 0;
	next = 1;
	#5;
	next = 0;
	#30;
	
	#5000;
	
    
  end
  
endmodule 