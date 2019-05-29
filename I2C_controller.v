module I2C_controller(
	input clock_25,
	input [15:0] register_data,
	input [7:0] slave_address,
	input i2c_serial_data_input,
	input start,
	
	output reg stop,
	output reg ack,
	output reg i2c_serial_data_output,
	output reg i2c_serial_clock
);

reg [7:0] count;
reg [8:0] temp;
reg [3:0] currentState;
reg setup = 1;

reg [7:0] bytes;
parameter [7:0] byte_num = 2;

always @(posedge(clock_25))
begin
	if(setup == 1) begin
		currentState <= 0;
		i2c_serial_data_output <= 1;
		i2c_serial_clock <= 1;	
		ack <= 0;
		count <= 0;
		stop <= 1;
		bytes <= 0;
		if(start == 1) begin
			currentState <= 10;
		end
		
		setup <= 0;
	end else begin
		case(currentState)
			0: 
				begin
					{i2c_serial_data_output, i2c_serial_clock} <= 2'b01; //start condition
					temp <= {slave_address, 1'b1}; //write
					currentState <= 1;
				end
				
			1: 
				begin
					{i2c_serial_data_output, i2c_serial_clock} <= 2'b00;
					currentState <= 2;
				end
			
			2: 
				begin
					{i2c_serial_data_output, temp} <= {temp,1'b0};
					currentState <= 3;
				end
				
			3: 
				begin
					i2c_serial_clock <= 1'b1;
					count <= count + 1;
					currentState <= 4;
				end
				
			4: 
				begin
					i2c_serial_clock <= 1'b0;
					if(count == 9) begin
						if(bytes == byte_num) begin
							currentState <= 5;
						end else begin
							count <= 0;
							currentState <= 1;
							
							if(bytes == 0) begin
								temp <= {register_data[15:8], 1'b1};
								bytes <= 1;
							end else if(bytes == 1) begin
								temp <= {register_data[15:8], 1'b1};
								bytes <= 2;
							end
						end
						if(i2c_serial_data_input) begin
							ack <= 1;
						end
					end else begin
						currentState <= 1;
					end	
				end
				
			5: 
				begin
					{i2c_serial_data_output, i2c_serial_clock} <= 2'b00; 
					currentState <= 6;
				end
				
			6: 
				begin
					{i2c_serial_data_output, i2c_serial_clock} <= 2'b01; 
					currentState <= 7;
				end
				
			7: 
				begin
					{i2c_serial_data_output, i2c_serial_clock} <= 2'b11; 
					currentState <= 8;
				end
				
			8: 
				begin
					i2c_serial_data_output <= 1;
					i2c_serial_clock <= 1;	
					ack <= 0;
					count <= 0;
					stop <= 1;
					bytes <= 0;
					currentState <= 9;
				end
				
			9: 
				begin
					if(start == 0) begin
						ack <= 0;
						stop <= 0;
						currentState <= 0;
					end
				end
				
			default: 
				begin
					
				end
		
		
		endcase
	end
	i2c_serial_data_output <= {slave_address, register_data};
end


endmodule