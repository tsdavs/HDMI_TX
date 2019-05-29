module image_output (
	input [3:0] mode,
	input clock_25,
	
	output pixel_clock,
	output reg data_enable,
	output horz_sync,
	output vert_sync,
	output reg [7:0] red,
	output reg [7:0] green,
	output reg [7:0] blue
	//output reg output_flag
);

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

wire _draw_flag;

vertical_draw v_draw (
	.clock_25(clock_25),
	
	.v_back_porch(_v_back_porch),
	.v_front_porch(_v_front_porch),
	.v_sync_length(_v_sync_length),
	.v_active_pixels(_v_active_pixels),
	.v_total_pixels(_v_total_pixels),
	
	.h_back_porch(_h_back_porch),
	.h_front_porch(_h_front_porch),
	.h_sync_length(_h_sync_length),
	.h_active_pixels(_h_active_pixels),
	.h_total_pixels(_h_total_pixels),
	
	.h_sync(horz_sync),
	.v_sync(vert_sync),
	.draw_flag(_draw_flag)
);

always @(posedge pixel_clock or posedge _draw_flag)
	begin
		data_enable <= 1'b1;
		if(_draw_flag == 1'b1)
			begin
				{red, green, blue} <= {8'hFF, 8'hFF, 8'hFF};
			end
	end

endmodule