module i2c_master #(parameter frame_numb = 1,
					localparam Data_size = 8) 
(
	input  					i_clk,    
	input  					i_rst_n,  
	input [Data_size-1: 0]  i_Data,
	input  					i_rw,
	inout  					io_sda,
	output 					o_done,
	output 					o_data
	output reg 				o_scl	
);

localparam IDLE = 0, START = 1, ADDR = 2, RW = 3, ADDR_ACK = 4,
		   W_SAMPLE = 5, R_SAMPLE = 6, M_ACK = 7, S_ACK = 8, STOP = 9;


reg [3:0] 				state;
reg [5:0]  frame_count = 0;// добавить log
reg serial_Data_out;
reg serial_Data_in;
assign o_scl = (state == IDLE || state == START || state == STOP) ? 1'b1 : i_clk;

assign io_sda = (we) ? serial_Data_out : 1'bz;
assign serial_Data_in = (~we) ? io_sda : 1'bx;

always @(posedge i_clk or negedge i_rst_n) begin 
 	if(~i_rst_n) begin
 		state  <= idle;
 		io_sda <= 1'b1;

 	end else begin
 		 case (state)
 		 	IDLE: begin
 		 		state = START;

 		 	end

 		 	START: begin
 		 		state = ADDR;
 		 		
 		 	end

 		 	ADDR: begin
 		 		state = RW;
 		 	end

 		 	RW: begin
 		 		state = ADDR_ACK;
 		 	end

 		 	ADDR_ACK: begin
 		 		if(io_sda == 1 && ) // SDA == 1 is okay else it's not okay
 		 			state = 
 		 		else
 		 			state = STOP;
 		 	end

 		 	W_SAMPLE: begin
 		 		frame_count = frame_count + 1;
 		 		state = S_ACK;
 		 	end

 		 	R_SAMPLE: begin
 		 		frame_count = frame_count + 1;
 		 		state = M_ACK;
 		 	end

 		 	M_ACK: begin
 		 		if(io_sda == 1 && frame_count == )
 		 	end

 		 	S_ACK: begin

 		 	end

 		 	STOP: begin

 		 	end

 		 	default : /* default */;
 		 endcase
 	end
 end 

endmodule
