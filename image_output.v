module image_output (
	input [3:0] mode,
	
	output pixel_clock,
	output reg data_enable,
	output horz_sync,
	output vert_sync,
	output reg [7:0] red,
	output reg [7:0] green,
	output reg [7:0] blue,
	output reg output_flag

);

always @ (posedge pixel_clock or posedge output_flag)
	begin
		data_enable <= 1'b1;
		
		{red, green, blue} <= {8'hFF,8'hFF,8'hFF};
	end



endmodule