`timescale 1ns / 1ps

module testbench;

reg i_clk, i_rst_n;
reg [7:0]  i_Data;
reg [7:0]  i_addr;
reg 	   i_rw;
reg 	   i_start;
wire 	   io_sda;
wire 	   o_done;
wire [7:0] o_data;
wire	   o_scl;

reg we;

assign io_sda = (we) ? 0 : 1'bz;

i2c_master test1(.i_clk  (i_clk),
				 .i_rst_n(i_rst_n),
				 .i_Data (i_Data),
				 .i_addr (i_addr),
				 .i_rw   (i_rw),
				 .i_start(i_start),
				 .io_sda (io_sda),
				 .o_done (o_done),
				 .o_data (o_data),
				 .o_scl  (o_scl)
				 );

initial begin
	i_clk = 0;
	forever #20 i_clk = ~i_clk;
end

initial begin
	i_rst_n = 0;
	#40 i_rst_n = 1;
end

initial begin
	i_start = 0;
	#40 i_start = 1;
	#40 i_start = 0;
end

initial begin
	i_rw   = 1;
	i_addr = 8'b10110111;
	i_Data = 8'b00101110;
end

initial begin
	we = 0;
	#460 we = 1;
	#20  we = 0;
end


initial #1200 $finish;

endmodule 