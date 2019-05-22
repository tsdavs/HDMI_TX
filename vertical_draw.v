//vertical draw counter state machine that draws
//depending on front port/ back porch etc.
//v_d controls the horizontal draw when it should draw
//if no data should be out pixels are zero.

//ref: https://www.digi.com/resources/documentation/digidocs/90001945-13/reference/yocto/r_an_adding_custom_display.htm

module vertical_draw (
	input clock_50,
	input [11:0] v_back_porch,
	input [11:0] v_front_porch,
	input [11:0] v_sync_length,
	input [11:0] v_active_pixels,
	input [11:0] v_total_pixels,
			
	output reg h_draw_flag,
	output reg v_draw_flag
);

reg [9:0] vert_pxl;

reg [1:0] currentState, nextState; //2 bit wide regs

parameter VBP = 2'b00; //vertical back porch
parameter VACTIVE = 2'b01; //vertical resolution
parameter VFP = 2'b10; //vertical front porch
parameter VSLEN = 2'b11; //vertical sync length

//updates the currentState/nextState transition @posedge(stateClock)
always @(posedge(clock_50))
	begin: stateMemory	
		// Update the state variable on the stateClock transition.
		currentState <= nextState;
		
		if(v_draw_flag == 1'b0 && h_draw_flag == 1'b0) begin
			//increment through vert pixels when not horz drawing
			vert_pxl = vert_pxl + 1'b1;
		end else if(h_draw_flag == 1'b1) begin
			//whilst horizontal is drawing just stay the same	
			vert_pxl <= vert_pxl;
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
					h_draw_flag = 1'b1;
					v_draw_flag = 1'b0;
				end
			VFP:
				begin
					h_draw_flag = 1'b0;
					v_draw_flag = 1'b0;
				end
			VSLEN:
				begin
					h_draw_flag = 1'b0;
					//restart counting vertical
					v_draw_flag = 1'b1;
				end
			default:
				begin
					h_draw_flag = 1'b0;
					v_draw_flag = 1'b0;
				end
			endcase
	end	
	

endmodule