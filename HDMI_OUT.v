module HDMI_OUT(

	input HDMI_TX_INT, //Interrupt signal
	
	inout I2C_SDA, //I2C data
	
	output I2C_SCL, //I2C Clock
	
	output [23:0] HDMI_TX_D, //Video data bus RGB 
	output HDMI_TX_CLK, //Video Clock
	output HDMI_TX_HS, //Horizontal sync
	output HDMI_TX_VS, //Vertical sync
	output HDMI_TX_DE, //Data enable signal for digital video
	
	output HDMI_I2S0, //I2S Channel 0 Audio Data 
	output HDMI_MCLK, //Audio reference clock 
	output HDMI_LRCLK, //Audio L/R channel signal
	output HDMI_SCLK, //I2S Audio clock 
);






endmodule