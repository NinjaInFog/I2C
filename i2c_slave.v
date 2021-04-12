module i2c_slave #(localparam Data_size = 8,
				   localparam Addr_size = 8) 
(
	input 				   i_clk,    // Clock
	input 				   i_rst_n, 
	input [Data_size-1:0]  i_Data,
	input [Addr_size-1:0]  i_Addr,
	input 				   i_scl,
	input				   i_start,
	inout 				   io_sda,	
	output				   o_done,
	output reg [Data_size-1:0] o_data
);

localparam IDLE = 0, START = 1, ADDR = 2, RW = 3, ADDR_ACK = 4,
		   W_SAMPLE = 5, R_SAMPLE = 6, M_ACK = 7, S_ACK = 8, STOP = 9;
wire 	   we;
reg [3:0]  state;
reg		   Serial_Data_out;
reg		   Serial_Data_in;
reg [7:0]  addr_check;
reg		   rw_read;
reg		   old_sda;
wire 	   sda_negedge;
wire 	   ack_addr;
reg [2:0]  count;
assign sda_negedge = ~old_sda && Serial_Data_in;
assign ack_addr = (addr_check == i_Addr) ? 1'b1 : 1'b0;
assign we = (state == ADDR_ACK || state == R_SAMPLE || state == S_ACK); 
assign io_sda = (we) ? Serial_Data_out : 1'bz;
assign Serial_Data_in = (~we) ? io_sda : 1'bx;

always @(posedge clk or negedge rst_n) begin : proc_
	if(~rst_n) begin
		old_sda    <= 0;
		state 	   <= IDLE;
		count      <= 0;
		addr_check <= 0;
		rw_read	   <= 1'bx;
	end else begin
		 case (state)
		 	IDLE: begin
		 		if(i_start)
		 			state <= START;
		 		else
		 			state <= IDLE;
		 	end

		 	START: begin
		 		old_sda <= Serial_Data_in;
		 		if(sda_negedge && i_scl)
		 			state <= ADDR_ACK;
		 		else
		 			state <= START;
		 	end

		 	ADDR_ACK: begin
		 		addr_check[count] <= Serial_Data_in;
		 		if(count == (Addr_size-1)) begin
		 			count <= 0;
		 			state <= RW;
		 		end else begin
		 				count <= count + 1;
		 				state <= RW;
		 		end
		 	end

		 	RW: begin
		 		rw_read <= Serial_Data_in;
		 		state   <= ADDR_ACK;
		 	end

		 	ADDR_ACK: begin
		 		if(ack_addr) begin
		 			Serial_Data_out <= 1'b1;
		 			if(rw_read)
		 				state <= W_SAMPLE;
		 			else
		 				state <= R_SAMPLE;
		 		end else begin
		 			Serial_Data_out <= 1'b0;
		 		end
		 	end

		 	W_SAMPLE: begin
		 		Serial_Data_out <= i_Data[count];
		 		if(count == (Addr_size - 1)) begin
 		 			count  <= 0;
 		 			state  <= M_ACK; 		 			
 		 		end
 		 		else begin
 		 			count <= count + 1;
 		 			state <= W_SAMPLE;
 		 		end
		 	end

		 	R_SAMPLE: begin
		 		o_data[count] <= Serial_Data_in;
		 		if(count == (Addr_size-1)) begin
		 			count <= 0;
		 			state <= S_ACK;
		 		end else begin
		 			count <= count + 1;
		 			state <= R_SAMPLE;
		 		end
		 	end

		 	default : /* default */;
		 endcase
	end
end

endmodule