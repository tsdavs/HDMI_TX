module HDMI_OUT(
	input key1, //for testing i2c loading

	input _clock_50, //50 MHz fpga clock
	input HDMI_TX_INT, //Interrupt signal

	inout I2C_SDA, //I2C data
	
	inout I2C_SCL, //I2C Clock
	output [23:0] HDMI_TX_D, //Video data bus RGB 
	output HDMI_TX_CLK, //Video Clock
	output HDMI_TX_HS, //Horizontal sync
	output HDMI_TX_VS, //Vertical sync
	output HDMI_TX_DE//, //Data enable signal for digital video
	
	//GPIO pins for testing
	/*output sda_test, //ac24
	output scl_test, //y15
	output reset, 
	output data_enable_test, //ag28
	output hdmi_clock, //ad26
	output hdmi_data_test, //aa15
	output vs_test, //ae25
	output hs_test //af28*/

);

//Assign to GPIO pins for testing
/*assign vs_test = HDMI_TX_VS;
assign hs_test = HDMI_TX_HS;
assign data_enable_test = HDMI_TX_DE;
assign hdmi_clock = HDMI_TX_CLK;
assign hdmi_data_test = HDMI_TX_D[1];
assign sda_test = I2C_SDA;
assign scl_test = I2C_SCL;
assign reset = key1;*/

reg _clock_25;

pll clock_25(
	.refclk   (_clock_50),  
	.rst      (),     
	.outclk_0 (_clock_25), 
	.locked   ()   
);
	
image_output i_output (
	//inputs
	.clock_50(_clock_50),

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