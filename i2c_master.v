module i2c_master #(parameter frame_numb = 1,
					localparam Data_size = 8,
					localparam Addr_size = 8) 
(
	input  						i_clk,    
	input  						i_rst_n,  
	input [Data_size-1: 0]  	i_Data,
	input [Addr_size-1: 0]  	i_addr,
	input  						i_rw,
	input 						i_start,
	inout  						io_sda,
	output 						o_done,
	output reg [Data_size-1:0]  o_data,
	output reg 					o_scl	
);

localparam IDLE = 0, START = 1, ADDR = 2, RW = 3, ADDR_ACK = 4,
		   W_SAMPLE = 5, R_SAMPLE = 6, M_ACK = 7, S_ACK = 8, STOP = 9;

reg 	   scl_en;
wire 	   we;
reg [3:0]  state;
reg [5:0]  frame_count = 0;// добавить log
reg 	   serial_Data_out;
reg 	   serial_Data_in;
reg [2:0]  count = 0;


assign io_sda = (we) ? serial_Data_out : 1'bz;
assign serial_Data_in = (~we) ? io_sda : 1'bx;
assign we = (state == START || state == ADDR || state == RW || 
			 state == W_SAMPLE || state == M_ACK || state == STOP);


assign o_scl = (scl_en) ? 1'b1 : ~i_clk;

always @(negedge i_clk or negedge i_rst_n) begin 
	if(~i_rst_n) begin
		scl_en <= 1;
	end else begin
		 if(state == IDLE || state == START || state == STOP) begin
		 	scl_en <= 1'b1;
		 end
		 else
		 	scl_en <= 1'b0;
	end
end




always @(posedge i_clk or negedge i_rst_n) begin 
 	if(~i_rst_n) begin
 		state  <= IDLE;
 		serial_Data_out <= 1'b1;

 	end else begin
 		 case (state)
 		 	IDLE: begin
 		 		if(i_start == 1)
 		 			state <= START;
 		 		else
 		 			state <= IDLE;
 		 	end

 		 	START: begin
 		 		serial_Data_out <= 0;
 		 		state  <= ADDR;
 		 	end

 		 	ADDR: begin
 		 		serial_Data_out  <= i_addr[count];
 		 		if(count == (Addr_size - 1)) begin
 		 			state  <= RW;
 		 			count <= 0;
 		 		end
 		 		else begin
 		 			count = count + 1;
 		 			state <= ADDR;
 		 		end
 		 	end

 		 	RW: begin
 		 		serial_Data_out <= i_rw;
 		 		state  <= ADDR_ACK;
 		 	end

 		 	ADDR_ACK: begin
/* 		 		if(serial_Data_in == 1 && i_rw == 1) begin
 		 			state <= W_SAMPLE;
 		 		end else if(serial_Data_in == 1 && i_rw == 0)
 		 			state <= R_SAMPLE;
 		 		else
 		 			state <= STOP;*/
 		 		if(i_rw == 1)
 		 			state <= W_SAMPLE;
 		 		else
 		 			state <= R_SAMPLE;
 		 	end

 		 	W_SAMPLE: begin
 		 		serial_Data_out <= i_Data[count];
 		 		if(count == (Addr_size - 1)) begin
 		 			count <= 0;
 		 			state <= S_ACK;
  		 		end else begin
 		 			count <= count + 1;
 		 			state <= W_SAMPLE;
 		 		end
 		 		
 		 	end

 		 	R_SAMPLE: begin
 		 		o_data[count] <= serial_Data_in;
 		 		if(count == (Addr_size - 1)) begin
 		 			count  <= 0;
 		 			state  <= M_ACK; 		 			
 		 		end
 		 		else begin
 		 			count <= count + 1;
 		 			state <= R_SAMPLE;
 		 		end
 		 	end

 		 	M_ACK: begin
 		 		state <= STOP;
 		 	end

 		 	S_ACK: begin
 		 		state <= STOP;
 		 	end

 		 	STOP: begin
 		 		serial_Data_out <= 1;
 		 		state  <= IDLE;
 		 	end

 		 	default : /* default */;
 		 endcase
 	end
 end 

endmodule