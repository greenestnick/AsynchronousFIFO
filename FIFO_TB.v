`include "./FIFO.v"

`define NUM 8
`define WORD 8

module FIFO_TB();
	
	//Set up
	reg wclk, rclk, ren, wen, rst;
	reg [`WORD - 1 : 0] w_word;
	wire [`WORD - 1 : 0] r_word;
	wire full, empty;

	FIFO fifo (ren, wen, rclk, wclk, rst, w_word, r_word, full, empty);

	reg [2:0] lastRPtr = 3'b0;

	

	initial begin
		wclk = 1'b0;
		rclk = 1'b0;
		ren = 1'b0;
		wen = 1'b0;
		rst = 1'b0;
		w_word = 8'b0;

		lastRPtr = 3'b0;
		
		repeat(2) #5 rst = ~rst;
		$display("=== RESET AND STARTING ===");	
		wen = 1'b1;
		ren = 1'b1;
		$monitor("Full:%b Empty:%b", full, empty);
	end
	
	//Write with a clock period of 6
	always begin
		#15
		repeat (`NUM) begin
			w_word = w_word + 1;
			$display("%t: Writing: %d", $time, w_word);

			repeat(2) #3 wclk = ~wclk;
		end
	end

	//read with clock period of 12 
	always begin
		#15

		repeat(`NUM) begin
			lastRPtr = fifo.rCounterBinary[2:0];
			repeat (2) #6 rclk = ~rclk;
			$display("\t\t\t%t:Reading: %d", $time, r_word);
		end

		
		for(integer i = 0; i < 8; i = i + 1) $display("%d \n", fifo.mem.memArray[i]); 

		$finish;
	end



endmodule
