module testbench();
  
  logic clk, randomize, next, start_over;
  logic [3:0] seq;
  
  sequence_generator dut(.clk, .randomize, .next, .start_over, .seq);
  
  always begin
    clk = 0; #5; clk = 1; #5;
  end
  
  initial begin
    
    #2;
    
    randomize = 1;
    next = 1;
    start_over = 1;
    
    #20;
    
    randomize = 0;
    start_over = 0;
    next = 1;
    
    #5000;
    
  end
  
endmodule 