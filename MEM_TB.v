
`include "./MEM.v"

module MEM_TB();

	reg [`LEN_POW - 1 : 0] r_addr, w_addr;
	reg [`WORD - 1 : 0] w_word;
	reg clk, rst, ena;
	wire [`WORD - 1 : 0] r_word;

	MEM mem (.clk(clk), .rst(rst), .ena(ena), .r_word(r_word), .r_addr(r_addr), .w_addr(w_addr), .w_word(w_word));

	initial begin
		clk = 1'b0;
		rst = 1'b0;
		ena = 1'b0;
		r_addr = 3'b0;
		w_addr = 3'b0;
		w_word = 8'b0;

		repeat(2) #5 rst = ~rst;
		ena = 1'b1;

		repeat(8) begin
			//$display("\n%t: \n", $time);
			//for(integer i = 0; i < `LEN; i = i + 1) $display("%d\n", mem.memArray[i]);
			
			repeat(2) #5 clk = ~clk;
			w_word = w_word + 1;
			w_addr = w_addr + 1;
		end

		for(integer i = 0; i < `LEN; i = i + 1) $display("%d,  ", mem.memArray[i]);
		$display("\n");

		repeat(8) begin
			repeat(2) #5 clk = ~clk;
			$display("%x --> %d\n", r_addr, r_word);

			r_addr = r_addr + 1;
		end
		
	end

endmodule
