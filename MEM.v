module MEM
#(
	parameter WORD_SIZE = 8,
	parameter ADDR_SIZE = 3

)(
	input [ADDR_SIZE - 1 : 0]  r_addr, w_addr,
	input [WORD_SIZE - 1 : 0] w_word,
	input rclk, wclk, rena, wena, rst,
	output reg [WORD_SIZE - 1 : 0] r_word
);

parameter ADDR_MAX = 1 << ADDR_SIZE;

reg [WORD_SIZE - 1 : 0] memArray [ADDR_MAX - 1 : 0];

always @(posedge rst) begin
	for(integer i = 0; i < ADDR_MAX; i = i + 1) memArray[i] = 8'b0;		
end

always @(posedge wclk) begin
	if(wena) memArray[w_addr] = w_word;
end

always @(posedge rclk) begin
	if(rena) r_word = memArray[r_addr];
end

endmodule
