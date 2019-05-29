//vertical draw counter state machine that draws
//depending on front port/ back porch etc.
//v_d controls the horizontal draw when it should draw
//if no data should be out pixels are zero.

//ref: https://www.digi.com/resources/documentation/digidocs/90001945-13/reference/yocto/r_an_adding_custom_display.htm

module vertical_draw (
	input clock_25,
	input [11:0] v_back_porch,
	input [11:0] v_front_porch,
	input [11:0] v_sync_length,
	input [11:0] v_active_pixels,
	input [11:0] v_total_pixels,	

	input [11:0] h_back_porch,
	input [11:0] h_front_porch,
	input [11:0] h_sync_length,
	input [11:0] h_active_pixels,
	input [11:0] h_total_pixels,
	
	output reg h_sync,
	output reg v_sync,
	output reg draw_flag

);

reg h_count_flag;

reg [9:0] vert_pxl = 0;
reg [9:0] horz_pxl = 0;

reg vert_setup = 1;
reg horz_setup = 1;

//vertical drawing loop
always @(posedge(clock_25))
	begin
		if(vert_setup == 1) begin 
			h_count_flag = 1'b0;
			v_sync = 1'b0;
			vert_setup = 0;
		end else begin
			if(h_count_flag == 1'b0) begin
				//increment through vert pixels when not horz drawing
				vert_pxl = vert_pxl + 1'b1;
			end else begin
				//increment through horz pixels when vert is waiting
				horz_pxl = horz_pxl + 1'b1;
			end
			
			//in the vactive region
			if(vert_pxl > v_back_porch && vert_pxl < (v_back_porch + v_active_pixels)) begin
				//start drawing horizontal
				h_count_flag <= 1'b1;
			end else begin
				h_count_flag <= 1'b0;
			end	
			
			//setting vsync
			if(vert_pxl > (v_back_porch + v_active_pixels + v_front_porch) && vert_pxl < v_total_pixels) begin
				v_sync = 1'b1;
			end else begin
				v_sync = 1'b0;
			end
			
			//if count goes past total, start again
			if(vert_pxl > v_total_pixels)begin
				vert_pxl <= 1'b0;
			end	
		end

		//horizontal drawing loop
		if(horz_setup == 1) begin 
			draw_flag = 1'b0;
			h_sync = 1'b0;
			horz_setup = 0;
		end else begin	
			if(horz_pxl > h_back_porch && horz_pxl < (h_back_porch + h_active_pixels)) begin
				//start drawing 
				draw_flag <= 1'b1;
			end else begin
				draw_flag <= 1'b0;
			end	
			
			//setting hsync
			if(horz_pxl > (h_back_porch + h_active_pixels + h_front_porch) && horz_pxl < h_total_pixels) begin
				h_sync = 1'b1;
			end else begin
				h_sync = 1'b0;
			end
			
			//if count goes past total, start again
			if(horz_pxl > h_total_pixels)begin
				horz_pxl <= 1'b0;
				h_count_flag <= 1'b0;
			end		
		end
	end
endmodule