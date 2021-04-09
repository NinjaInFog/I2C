module i2c_master (
	input i_clk,    // Clock
	input i_rst_n,  // Asynchronous reset active low
	inout io_sda,
	output reg o_scl	
);

localparam IDLE = 0, START = 1, ADDR = 2, RW = 3, NACK = 4,
		   SAMPLE = 5, SAMP_ACK = 6, STOP = 7;


reg [2:0] state;

always @(posedge clk) begin 
	if(state == IDLE || state == START || state == STOP) 
		o_scl <= 1'b1;
	else
		o_scl <= i_clk;
end

assign io_sda = (we) ? temp_out : 1'bz;

always @(posedge clk or negedge i_rst_n) begin 
 	if(~i_rst_n) begin
 		state  <= idle;
 		io_sda <= 1'b1;

 	end else begin
 		 case (state)
 		 	IDLE: begin
 		 		state = START;
 		 	end

 		 	START: begin

 		 	end

 		 	ADDR: begin

 		 	end

 		 	RW: begin

 		 	end

 		 	NACK: begin

 		 	end

 		 	SAMPLE: begin

 		 	end

 		 	SAMP_ACK: begin

 		 	end

 		 	STOP: begin

 		 	end
 		 	default : /* default */;
 		 endcase
 	end
 end 

endmodule