//vertical draw counter state machine that draws
//depending on front port/ back porch etc.
//v_d controls the horizontal draw when it should draw
//if no data should be out pixels are zero.

//ref: https://www.digi.com/resources/documentation/digidocs/90001945-13/reference/yocto/r_an_adding_custom_display.htm
module vertical_draw (
	input pixel_clock,
	input	reset_n,
	input [11:0] v_back_porch,
	input [11:0] v_sync_length,
	input [11:0] v_total_pixels,	
	input	[11:0] v_start,           
	input	[11:0] v_end,

	input [11:0] h_sync_length,
	input [11:0] h_total_pixels,
	input	[11:0] h_start,             
	input	[11:0] h_end,   
	
	output reg h_sync,
	output reg v_sync,
	output reg data_enable,
	output reg [7:0] vga_r,
	output reg [7:0] vga_g,
	output reg [7:0] vga_b
);

reg [9:0] vert_pxl = 0;
reg [9:0] horz_pxl = 0;
reg h_act; 
reg h_act_d;
reg v_act; 
reg v_act_d; 
reg pre_vga_de;

//vertical drawing loop
always@(posedge pixel_clock or negedge reset_n) 
begin
	if(!reset_n) begin
		v_act_d <= 1'b0;
		vert_pxl <= 12'b0;
		v_sync <= 1'b1;
		v_act <= 1'b0;
	end else begin		
		if (horz_pxl == h_total_pixels) begin		  
			v_act_d <= v_act;
		  
			if (vert_pxl == v_total_pixels) begin
				vert_pxl <= 12'b0;
			end else begin
				vert_pxl <= vert_pxl + 1;
			end
				
			if (vert_pxl >= v_sync_length && vert_pxl != v_total_pixels) begin
				v_sync <= 1'b1;
			end else begin
				v_sync <= 1'b0;
			end
			
			if (vert_pxl == v_start) begin
				v_act <= 1'b1;
			end else if (vert_pxl == v_end) begin
				v_act <= 1'b0;
			end
		end
	end
end

//horizontal drawing loop
always @ (posedge pixel_clock or negedge reset_n)
begin
	if (!reset_n) begin
			h_act_d <= 1'b0;
			horz_pxl <= 12'b0;
			h_sync <= 1'b1;
			h_act <= 1'b0;
	end else begin
		h_act_d <= h_act;

		if (horz_pxl == h_total_pixels) begin
			horz_pxl <= 2'b0;
		end else begin
			horz_pxl <= horz_pxl + 1;
		end
			
		if (horz_pxl >= h_sync_length && horz_pxl != h_total_pixels) begin
			h_sync <= 1'b1;
		end else begin
			h_sync <= 1'b0;
		end
		
		if (horz_pxl == h_start) begin
			h_act <= 1'b1;
		end else if (horz_pxl == h_end) begin
			h_act <= 1'b0;
		end
	end
end

//pattern generator and display enable
always @(posedge pixel_clock or negedge reset_n)
begin
	if (!reset_n) begin
		data_enable <= 1'b0;
		pre_vga_de <= 1'b0;
	end else begin
		data_enable <=	pre_vga_de;
		pre_vga_de <= v_act && h_act;
    
		{vga_r, vga_g, vga_b} <= {8'hFF,8'hFF,8'hFF};
		
	end
end	

endmodule