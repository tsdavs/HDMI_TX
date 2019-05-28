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
	
	output reg h_count_flag,
	output reg draw_flag

);

reg [9:0] vert_pxl = 0;
reg [9:0] horz_pxl = 0;

//reg [1:0] currentState = 0;
//reg [1:0] nextState = 0; //2 bit wide regs
reg setup = 1;
/*
parameter VBP = 2'b00; //vertical back porch
parameter VACTIVE = 2'b01; //vertical resolution
parameter VFP = 2'b10; //vertical front porch
parameter VSLEN = 2'b11; //vertical sync length
*/
//vertical drawing loop
always @(posedge(clock_25))
	begin
		if(setup == 1) begin 
			h_count_flag = 1'b0;
			draw_flag = 1'b0;
			setup = 0;
		end 
		
		if(h_count_flag == 1'b0) begin
			//increment through vert pixels when not horz drawing
			vert_pxl = vert_pxl + 1'b1;
		end
		
		//in the vactive region
		if(vert_pxl > v_back_porch && vert_pxl < (v_back_porch + v_active_pixels)) begin
			//start drawing horizontal
			h_count_flag <= 1'b1;
		end else begin
			h_count_flag <= 1'b0;
		end	
		
		//if count goes past total, start again
		if(vert_pxl > v_total_pixels)begin
			vert_pxl <= 1'b0;
		end			
	end
	
//horizontal drawing loop
always @(posedge(clock_25))
	begin
		if(h_count_flag == 1'b1) begin
			//increment through horz pixels when vert is waiting
			horz_pxl = horz_pxl + 1'b1;
		end
		
		if(horz_pxl > h_back_porch && horz_pxl < (h_back_porch + h_active_pixels)) begin
			//start drawing 
			draw_flag <= 1'b1;
		end else begin
			draw_flag <= 1'b0;
		end	
		//if count goes past total, start again
		if(horz_pxl > h_total_pixels)begin
			horz_pxl <= 1'b0;
			h_count_flag <= 1'b0;
		end		
	
	end

/*reg [2:0] currentState, nextState; //3 bit wide regs

parameter HBP = 3'b000; //horizontal back porch
parameter HACTIVE = 3'b001; //horizontal resolution
parameter HFP = 3'b010; //horizontal front porch
parameter HSLEN = 3'b011; //horizontal sync length
parameter RESTART = 3'b100; //restart horizontal draw*/

//updates the currentState/nextState transition @posedge(stateClock)
/*always @(posedge(clock_50))
	begin: stateMemory	
		// Update the state variable on the stateClock transition.
		currentState <= nextState;
		
		if(h_draw_flag == 1'b1) begin
				horz_pxl <= horz_pxl + 1'b1;
		end else begin
				horz_pxl <= 1'b0;
		end
	end*/
	

//handles state transitions
/*always @(currentState or horz_pxl)
	begin: nextStateLogic
		case(currentState)
			HBP:
				begin
					if(horz_pxl > h_back_porch)
					begin
						nextState = HACTIVE;
					end
				end
			HACTIVE:
				begin
				if(horz_pxl > (h_back_porch + h_active_pixels))
					begin
						nextState = HFP;
					end				
				end
			HFP:
				begin
				if(horz_pxl > (h_back_porch + h_active_pixels + h_front_porch))
					begin
						nextState = HSLEN;
					end		
				end
			HSLEN:
				begin
				if(horz_pxl > h_total_pixels)
					begin
						nextState = RESTART;
					end			
				end
			RESTART:
				begin
					begin
						nextState = HBP;
					end			
				end
			default:
				begin
				end
			endcase
	end	
					

// Logic to handle the actual outputs.
always @(currentState)
	begin: outputLogic
		case(currentState)
			HBP:
				begin
					output_flag <= 1'b0;
					h_draw_flag <= 1'b1;

				end
			HACTIVE:
				begin
					//draw to screen
					output_flag <= 1'b1;
					h_draw_flag <= 1'b1;
				end
			HFP:
				begin
					output_flag <= 1'b0;
					h_draw_flag <= 1'b1;
				end
			HSLEN:
				begin
					output_flag <= 1'b0;
					h_draw_flag <= 1'b1;
				end
			RESTART:
				begin
					output_flag <= 1'b0;
					h_draw_flag <= 1'b0;
				end
			default:
				begin
					h_draw_flag <= 1'b0;
					output_flag <= 1'b0;
				end
			endcase
	end	*/


/*
//updates the currentState/nextState transition @posedge(stateClock)
always @(posedge(clock_50))
	begin//: stateMemory	
		// Update the state variable on the stateClock transition.
		currentState <= nextState;
		
		if(setup == 1) begin 
			h_draw_flag = 1'b0;
			v_draw_flag = 1'b0;
			setup = 0;
		end
		
		if(v_draw_flag == 1'b0 && h_draw_flag == 1'b0) begin
			//increment through vert pixels when not horz drawing
			vert_pxl = vert_pxl + 1'b1;
		end /*else if(h_draw_flag == 1'b1) begin
			//whilst horizontal is drawing just stay the same	
			//vert_pxl <= vert_pxl;
		end else begin
			//restart when done
			vert_pxl = 1'b0;
		end
	end
	

	//handles state transitions
always @(currentState or vert_pxl)
	begin: nextStateLogic
		case(currentState)
			VBP:
				begin
					if(vert_pxl > v_back_porch)
					begin
						nextState = VACTIVE;
					end
				end
			VACTIVE:
				begin
				if(vert_pxl > (v_back_porch + v_active_pixels))
					begin
						nextState = VFP;
					end				
				end
			VFP:
				begin
				if(vert_pxl > (v_back_porch + v_active_pixels + v_front_porch))
					begin
						nextState = VSLEN;
					end		
				end
			VSLEN:
				begin
				if(vert_pxl > v_total_pixels)
					begin
						nextState = VBP;
					end			
				end
			default:
				begin
				end
			endcase
	end	
					

// Logic to handle the actual outputs.
always @(currentState)
	begin: outputLogic
		case(currentState)
			VBP:
				begin
					h_draw_flag = 1'b0;
					v_draw_flag = 1'b0;
				end
			VACTIVE:
				begin
					//start drawing horizontal
					h_draw_flag <= 1'b1;
					v_draw_flag <= 1'b0;
				end
			VFP:
				begin
					h_draw_flag <= 1'b0;
					v_draw_flag <= 1'b0;
				end
			VSLEN:
				begin
					h_draw_flag <= 1'b0;
					//restart counting vertical
					v_draw_flag <= 1'b1;
				end
			default:
				begin
					h_draw_flag <= 1'b0;
					v_draw_flag <= 1'b0;
				end
			endcase
	end	*/

endmodule