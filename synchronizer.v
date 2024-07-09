

module synchronizer
#(
	parameter WORD_SIZE = 4
)
(
	input clk, rst,
	input [WORD_SIZE - 1 : 0] inWord,
	output reg [WORD_SIZE  - 1 : 0] outWord
);


reg [WORD_SIZE - 1 : 0]  outWordBuffer;

always @(posedge clk or rst) begin
	if(rst) begin
		outWordBuffer = {WORD_SIZE {1'b0}};
		outWord = {WORD_SIZE {1'b0}};
	end else begin
		outWordBuffer <= inWord;
		outWord       <= outWordBuffer;
	end
end


endmodule
