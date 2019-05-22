module HDMI_OUT(

	input _clock_50, //50 MHz fpga clock
	input HDMI_TX_INT, //Interrupt signal

	inout I2C_SDA, //I2C data
	
	output I2C_SCL, //I2C Clock
	output [23:0] HDMI_TX_D, //Video data bus RGB 
	output HDMI_TX_CLK, //Video Clock
	output HDMI_TX_HS, //Horizontal sync
	output HDMI_TX_VS, //Vertical sync
	output HDMI_TX_DE //Data enable signal for digital video
);

wire _h_draw_flag;
wire _v_draw_flag;
wire _output_flag;

wire [11:0] _v_back_porch = 12'd32; //33-1
wire [11:0] _v_front_porch = 12'd9; //10-1
wire [11:0] _v_sync_length = 12'd1; //2-1
wire [11:0] _v_active_pixels = 12'd479; //478-1
wire [11:0] _v_total_pixels = 12'd524; //525-1

wire [11:0] _h_back_porch = 12'd47; //48-1
wire [11:0] _h_front_porch = 12'd15; //16-1
wire [11:0] _h_sync_length = 12'd95; //96-1
wire [11:0] _h_active_pixels = 12'd639; //640-1
wire [11:0] _h_total_pixels = 12'd799; //800-1

wire [3:0] output_mode = 0; //640x480p60

vertical_draw v_draw (
	.clock_50(_clock_50),
	.v_back_porch(_v_back_porch),
	.v_front_porch(_v_front_porch),
	.v_sync_length(_v_sync_length),
	.v_active_pixels(_v_active_pixels),
	.v_total_pixels(_v_total_pixels),
	
	.h_draw_flag(_h_draw_flag),
	.v_draw_flag(_v_draw_flag),
);

horizontal_draw h_draw (
	.clock_50(_clock_50),
	.h_back_porch(_h_back_porch),
	.h_front_porch(_h_front_porch),
	.h_sync_length(_h_sync_length),
	.h_active_pixels(_h_active_pixels),
	.h_total_pixels(_h_total_pixels),
	
	.h_draw_flag(_h_draw_flag),
	.output_flag(_output_flag)
);

image_output i_output (
	.mode(output_mode),
	
	.pixel_clock(HDMI_TX_CLK),
	.data_enable(HDMI_TX_DE),
	.horz_sync(HDMI_TX_HS),
	.vert_sync(HDMI_TX_VS),
	.red(HDMI_TX_D[23:16]),
	.green(HDMI_TX_D[15:8]),
	.blue(HDMI_TX_D[7:0]),
	.output_flag(_output_flag)
);

endmodule