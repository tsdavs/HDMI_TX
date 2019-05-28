module I2C_controller(
	input clock_50,
	input [15:0] register_data,
	input [7:0] slave_address,
	input i2c_serial_data_input,
	
	output reg i2c_serial_data_output,
	output i2c_serial_clock
);


always @(posedge(clock_50))
begin
	i2c_serial_data_output <= {slave_address, register_data};
end


endmodule