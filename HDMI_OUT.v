module HDMI_OUT(
	input key1, //for testing i2c loading

	input _clock_50, //50 MHz fpga clock
	input HDMI_TX_INT, //Interrupt signal

	inout I2C_SDA, //I2C data
	
	output I2C_SCL, //I2C Clock
	output [23:0] HDMI_TX_D, //Video data bus RGB 
	output HDMI_TX_CLK, //Video Clock
	output HDMI_TX_HS, //Horizontal sync
	output HDMI_TX_VS, //Vertical sync
	output HDMI_TX_DE, //Data enable signal for digital video
	
	output sda_test,
	output scl_test,
	output reset
);

assign sda_test = I2C_SDA;
assign scl_test = I2C_SCL;
assign reset = key1;

reg _clock_25 = 0;

always @(posedge(_clock_50))
	begin
		if(_clock_25 == 0)
			begin
				_clock_25 = 1;
			end
		else
			begin
				_clock_25 = 0;
			end
	end

image_output i_output (
	//inputs
	.clock_25(_clock_25),

	//outputs
	.pixel_clock(HDMI_TX_CLK),
	.data_enable(HDMI_TX_DE),
	.horz_sync(HDMI_TX_HS),
	.vert_sync(HDMI_TX_VS),
	.red(HDMI_TX_D[23:16]),
	.green(HDMI_TX_D[15:8]),
	.blue(HDMI_TX_D[7:0])
);

I2C_config i2c_config(
	//inputs
	.reset(reset),
	.clock_25(_clock_25),
	.interrupt(HDMI_TX_INT),
	
	//inouts
	.i2c_serial_data(I2C_SDA),
	
	//outputs
	.i2c_serial_clock(I2C_SCL)
);

endmodule