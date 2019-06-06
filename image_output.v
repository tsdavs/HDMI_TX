//vertical draw counter state machine that draws
//depending on front port/ back porch etc.
//v_d controls the horizontal draw when it should draw
//if no data should be out pixels are zero.

//ref: https://www.digi.com/resources/documentation/digidocs/90001945-13/reference/yocto/r_an_adding_custom_display.htm

module image_output (
	input clock_50,
	input reset,
	
	output pixel_clock,
	output reg data_enable,
	output reg horz_sync,
	output reg vert_sync,
	output reg [7:0] red,
	output reg [7:0] green,
	output reg [7:0] blue
);

pll clock_25(
	.refclk   (clock_50),  
	.rst      (),     
	.outclk_0 (pixel_clock), 
	.locked   ()   
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

reg [9:0] vert_pxl = 0;
reg [9:0] horz_pxl = 0;
reg h_act; 
reg h_act_d;
reg v_act; 
reg v_act_d; 
reg pre_vga_de;

always@(posedge pixel_clock or negedge reset) 
begin
	if(!reset) begin
		v_act_d <= 1'b0;
		vert_pxl <= 12'b0;
		vert_sync <= 1'b1;
		v_act <= 1'b0;
		h_act_d <= 1'b0;
		horz_pxl <= 12'b0;
		horz_sync <= 1'b1;
		h_act <= 1'b0;
	end else begin	
		//vertical drawing loop	
		if (horz_pxl == _h_total_pixels) begin		  
			v_act_d <= v_act;
		  
			if (vert_pxl == _v_total_pixels) begin
				vert_pxl <= 12'b0;
			end else begin
				vert_pxl <= vert_pxl + 1;
			end
				
			if (vert_pxl >= _v_sync_length && vert_pxl != _v_total_pixels) begin
				vert_sync <= 1'b1;
			end else begin
				vert_sync <= 1'b0;
			end
			
			if (vert_pxl == (_v_back_porch + _v_sync_length)) begin
				v_act <= 1'b1;
			end else if (vert_pxl == (_v_back_porch + _v_sync_length + _v_active_pixels + 1)) begin
				v_act <= 1'b0;
			end
		end
		//horizontal drawing loop
		h_act_d <= h_act;

		if (horz_pxl == _h_total_pixels) begin
			horz_pxl <= 2'b0;
		end else begin
			horz_pxl <= horz_pxl + 1;
		end
			
		if (horz_pxl >= _h_sync_length && horz_pxl != _h_total_pixels) begin
			horz_sync <= 1'b1;
		end else begin
			horz_sync <= 1'b0;
		end
		
		if (horz_pxl == (_h_back_porch + _h_sync_length - 1)) begin
			h_act <= 1'b1;
		end else if (horz_pxl == (_h_back_porch + _h_sync_length + _h_active_pixels)) begin
			h_act <= 1'b0;
		end
	end
end

//pattern generator and display enable
always @(posedge pixel_clock or negedge reset)
begin
	if (!reset) begin
		data_enable <= 1'b0;
		pre_vga_de <= 1'b0;
	end else begin
		data_enable <=	pre_vga_de;
		pre_vga_de <= v_act && h_act;
    
		{red, green, blue} <= {8'hFF,8'h00,8'h00};
		
	end
end	

endmodule