module image_output (
	input clock_50,
	
	output pixel_clock,
	output data_enable,
	output horz_sync,
	output vert_sync,
	output [7:0] red,
	output [7:0] green,
	output [7:0] blue
);

//640x480p60
wire [11:0] _v_back_porch = 12'd33; //34-1
wire [11:0] _v_front_porch = 12'd9; //10-1
wire [11:0] _v_sync_length = 12'd1; //2-1
wire [11:0] _v_active_pixels = 12'd479; //478-1
wire [11:0] _v_total_pixels = 12'd524; //525-1

wire [11:0] _h_back_porch = 12'd47; //48-1
wire [11:0] _h_front_porch = 12'd15; //16-1
wire [11:0] _h_sync_length = 12'd95; //96-1
wire [11:0] _h_active_pixels = 12'd639; //640-1
wire [11:0] _h_total_pixels = 12'd799; //800-1

wire [63:0] reconfig_to_pll, reconfig_from_pll;
wire gen_clk_locked;
wire [31:0] mgmt_readdata, mgmt_writedata;
wire mgmt_read, mgmt_write;
wire [5:0] mgmt_address;

vertical_draw v_draw (
	.pixel_clock(pixel_clock),
	.reset_n(gen_clk_locked),
	.v_back_porch(_v_back_porch),
	.v_sync_length(_v_sync_length),
	.v_total_pixels(_v_total_pixels),
	.v_start(_v_back_porch + _v_sync_length),           
	.v_end(_v_back_porch + _v_sync_length + _v_active_pixels + 1), 

	.h_sync_length(_h_sync_length),
	.h_total_pixels(_h_total_pixels),
	.h_start(_h_back_porch + _h_sync_length - 1),             
	.h_end(_h_back_porch + _h_sync_length + _h_active_pixels),  
	
	.h_sync(horz_sync),
	.v_sync(vert_sync),
	.data_enable(data_enable),
	.vga_r(red), 
	.vga_g(green), 
	.vga_b(blue)
);

pll_reconfig u_pll_reconfig (
	.mgmt_clk(clock_50),
	.mgmt_reset(),
	.mgmt_readdata(mgmt_readdata),
	.mgmt_waitrequest(),
	.mgmt_read(mgmt_read),
	.mgmt_write(mgmt_write),
	.mgmt_address(mgmt_address),
	.mgmt_writedata(mgmt_writedata),
	.reconfig_to_pll(reconfig_to_pll),
	.reconfig_from_pll(reconfig_from_pll) 
);

pll u_pll (
	.refclk(clock_50),           
	.rst(),              
	.outclk_0(pixel_clock), 
	.locked(gen_clk_locked),           
	.reconfig_to_pll(reconfig_to_pll),  
	.reconfig_from_pll(reconfig_from_pll) 
);

pll_controller u_pll_controller (
	.clk(clock_50),
	.reset_n(),
	.mgmt_readdata(mgmt_readdata),
	.mgmt_read(mgmt_read),
	.mgmt_write(mgmt_write),
	.mgmt_address(mgmt_address),
	.mgmt_writedata(mgmt_writedata) 
);
	
//							  Reference - modified from 
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
	
endmodule