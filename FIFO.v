`include "./MEM.v"
`include "./synchronizer.v"

module FIFO
#(
	parameter WORD_SIZE = 8,
	parameter ADDR_SIZE = 3

)(
	input ren, wen,
	input rclk, wclk,
	input rst,
	input [WORD_SIZE - 1 : 0] w_word,
	output [WORD_SIZE - 1 : 0] r_word,
	output full, empty
);

parameter ADDR_MAX = 1 << ADDR_SIZE;

function [ADDR_SIZE : 0] Bin2GrayCode (input [ADDR_SIZE : 0] binCount);
begin	
	case (binCount)
		4'h0 : Bin2GrayCode = 4'b0000;	
		4'h1 : Bin2GrayCode = 4'b0001;
		4'h2 : Bin2GrayCode = 4'b0011;
		4'h3 : Bin2GrayCode = 4'b0010;
		4'h4 : Bin2GrayCode = 4'b0110;
		4'h5 : Bin2GrayCode = 4'b0111;
		4'h6 : Bin2GrayCode = 4'b0101;
		4'h7 : Bin2GrayCode = 4'b0100;

		4'h8 : Bin2GrayCode = 4'b1100;
		4'h9 : Bin2GrayCode = 4'b1101;
		4'hA : Bin2GrayCode = 4'b1111;
		4'hB : Bin2GrayCode = 4'b1110;
		4'hC : Bin2GrayCode = 4'b1010;
		4'hD : Bin2GrayCode = 4'b1011;
		4'hE : Bin2GrayCode = 4'b1001;
		4'hF : Bin2GrayCode = 4'b1000;
	endcase
end
endfunction

reg [ADDR_SIZE : 0] wCounterBinary, rCounterBinary;
reg [ADDR_SIZE : 0] wCounterGrayCode, rCounterGrayCode;
wire [ADDR_SIZE : 0] wSyncGC, rSyncGC;


//=========Dual Port Memory Unit=============
assign wFullEna = wen & ~full;
assign rFullEna = ren & ~empty;

MEM mem (.rclk(rclk), .wclk(wclk), .rst(rst), .rena(rFullEna), .wena(wFullEna), .w_word(w_word), .r_word(r_word), .w_addr(wCounterBinary[ADDR_SIZE - 1 : 0]), .r_addr(rCounterBinary[ADDR_SIZE - 1 : 0]) );

/*
=========================================
                Reset 
=========================================
*/
always @(posedge rst) begin
	wCounterBinary = 4'b0;
	rCounterBinary = 4'b0;
end

/*
========================================
    Synchros and Full/Empty Status        	
=========================================
*/

wire [ADDR_SIZE - 1 : 0] wAddrGC ; 
wire [ADDR_SIZE - 1: 0] rAddrGC; 
wire [ADDR_SIZE - 1: 0] wAddrSyncGC;
wire [ADDR_SIZE - 1: 0] rAddrSyncGC;

synchronizer #(.WORD_SIZE(ADDR_SIZE + 1)) wsync (.clk(wclk), .rst(rst), .inWord(rCounterGrayCode), .outWord(rSyncGC));
synchronizer #(.WORD_SIZE(ADDR_SIZE + 1)) rsync (.clk(rclk), .rst(rst), .inWord(wCounterGrayCode), .outWord(wSyncGC));

//Converting the N-bit gray codes to N-1 bit gray codes by xor-ing the first two MSBs
assign wAddrGC = {(^wCounterGrayCode[ADDR_SIZE -: 2]), wCounterGrayCode[0+:2]};
assign rAddrGC = {(^rCounterGrayCode[ADDR_SIZE -: 2]), rCounterGrayCode[0+:2]};
assign wAddrSyncGC = {(^wSyncGC[ADDR_SIZE -: 2]), wSyncGC[0+:2]};
assign rAddrSyncGC = {(^rSyncGC[ADDR_SIZE -: 2]), rSyncGC[0+:2]};

assign full = (wAddrGC == rAddrSyncGC) && (wCounterGrayCode[ADDR_SIZE] != rSyncGC[ADDR_SIZE]);
assign empty = (rAddrGC == wAddrSyncGC) && (rCounterGrayCode[ADDR_SIZE] == wSyncGC[ADDR_SIZE]);


/*
=========================================
         Gray Code Converters
=========================================
*/
always @(wCounterBinary) begin
	wCounterGrayCode = Bin2GrayCode(wCounterBinary);
end

always @(rCounterBinary) begin
	rCounterGrayCode = Bin2GrayCode(rCounterBinary);
end


/*
=========================================
             Binary Counters
=========================================
*/
always @(posedge wclk) begin
	if(wFullEna) begin	
		wCounterBinary = wCounterBinary + 1;
	end
end

always @(posedge rclk) begin
	if(rFullEna) begin
		rCounterBinary = rCounterBinary + 1;
	end
end


endmodule
