module image_generator (
	input pixel_clock,
	input draw_flag,
	
	output reg data_enable,
	output reg [7:0] red,
	output reg [7:0] green,
	output reg [7:0] blue
);

always @(posedge pixel_clock) //pixel clock
	begin
		data_enable <= 1'b1;
		
		if(draw_flag == 1'b1)
			begin
				{red, green, blue} <= {8'hFF, 8'hFF, 8'hFF};
			end
	end

endmodule