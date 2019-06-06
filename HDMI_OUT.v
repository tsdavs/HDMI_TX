module HDMI_OUT(
	input reset, //for testing i2c loading

	input _clock_50, //50 MHz fpga clock
	input HDMI_TX_INT, //Interrupt signal

	inout I2C_SDA, //I2C data
	
	inout I2C_SCL, //I2C Clock
	output [23:0] HDMI_TX_D, //Video data bus RGB 
	output HDMI_TX_CLK, //Video Clock
	output HDMI_TX_HS, //Horizontal sync
	output HDMI_TX_VS, //Vertical sync
	output HDMI_TX_DE, //Data enable signal for digital video
	
	output [7:0] GPIO
);

assign GPIO[0] = I2C_SCL;//y15
assign GPIO[1] = I2C_SDA;//ac24
assign GPIO[2] = HDMI_TX_D[1];//aa15
assign GPIO[3] = HDMI_TX_CLK;//ad26
assign GPIO[4] = HDMI_TX_DE;//ag28
assign GPIO[5] = HDMI_TX_HS;//af28
assign GPIO[6] = HDMI_TX_VS;//ae25
	
image_output i_output (
	//inputs
	.clock_50(_clock_50),
	.reset(reset),
	
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
	.clock_50(_clock_50),
	.interrupt(HDMI_TX_INT),
	
	//inouts
	.i2c_serial_data(I2C_SDA),
	
	//outputs
	.i2c_serial_clock(I2C_SCL)
);

endmodule