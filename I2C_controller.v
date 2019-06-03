module I2C_controller(
	input clock_100khz,
	input [15:0] register_data,
	input [7:0] slave_address,
	input i2c_serial_data_input,
	input start,
	
	output reg stop,
	output reg ack,
	output reg i2c_serial_data_output,
	output reg i2c_serial_clock
);

reg [7:0] count = 0;
reg [8:0] slave_address_write;
reg [3:0] currentState = 0;
reg setup = 1;

reg [7:0] bytes = 0;
parameter [7:0] byte_num = 2;

reg [7:0] slave_address_reg;

/*wire clock_100khz;

counter counter_100khz(
	.MR_n(1'b1),
	.CEP(1'b1),
	.PE_n(1'b1),
	.Dn(),
	.clock(clock_25),
	
	.Qn_out(),
	.TC_out(clock_100khz)
);*/

always @(posedge(clock_100khz))
	begin
		case(currentState)
			//start sequence
			0: 
				begin
					i2c_serial_data_output <= 1'b1;
					i2c_serial_clock <= 1'b1;
					ack <= 0;
					count <= 0;
					stop <= 1;
					bytes <= 0;
					
					if(start) begin
						currentState <= 1;
					end else if(!start) begin
						currentState <= 0;
					end
				end
		
			1: 
				begin
					i2c_serial_data_output <= 1'b0;
					i2c_serial_clock <= 1'b1;
					slave_address_reg = slave_address;
					slave_address_reg = slave_address_reg | 8'b00000000; //8'b00000001;
					slave_address_write <= slave_address_reg; //write
					currentState <= 2;
				end
				
			2: 
				begin
					i2c_serial_data_output <= 1'b0;
					i2c_serial_clock <= 1'b0;
					currentState <= 3;
				end
			//start sequence complete
			
			3: 
				begin
					{i2c_serial_data_output, slave_address_write} <= {slave_address_write, 1'b0};
					//i2c_serial_data_output <= slave_address;
					currentState <= 4;
				end
				
			4: 
				begin
					i2c_serial_clock <= 1'b1;
					count <= count + 1;
					currentState <= 5;
				end
				
			5: 
				begin
					i2c_serial_clock <= 1'b0;
					
					if(count == 9) begin
						if(bytes == byte_num) begin
							currentState <= 6;
						end else begin
							count <= 0;
							currentState <= 2;
							
							if(bytes == 0) begin
								//slave_address_write <= register_data[15:8];
								//slave_address_write = slave_address_write | 9'b000000000;
								slave_address_write <= {register_data[15:8], 1'b0};
								bytes <= 1;
							end else if(bytes == 1) begin
								//slave_address_write <= register_data[7:0];
								//slave_address_write = slave_address_write | 9'b000000000;
								slave_address_write <= {register_data[7:0], 1'b0};
								bytes <= 2;
							end
						end
						if(i2c_serial_data_input) begin
							ack <= 1;
						end
					end else begin
						currentState <= 2;
					end	
				end
				
			6: 
				begin
					{i2c_serial_data_output, i2c_serial_clock} <= 2'b00; 
					currentState <= 7;
				end
				
			7: 
				begin
					{i2c_serial_data_output, i2c_serial_clock} <= 2'b01; 
					currentState <= 8;
				end
				
			8: 
				begin
					{i2c_serial_data_output, i2c_serial_clock} <= 2'b11; 
					currentState <= 9;
				end
				
			9: 
				begin
					i2c_serial_data_output <= 1;
					i2c_serial_clock <= 1;	
					ack <= 0;
					count <= 0;
					stop <= 1;
					bytes <= 0;
					currentState <= 10;
				end
				
			10: 
				begin
					//if(start == 0) begin
						ack <= 0;
						stop <= 0;
						currentState <= 0;
					//end
				end
			11:
				begin
				
				end
				
			default: 
				begin
					
				end
		
		
		endcase
end


endmodule