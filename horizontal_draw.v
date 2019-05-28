//horizontal draw counter state machine that draws
//depending on front port/ back porch etc.
//v_d controls the horizontal draw when it should draw
//if no data should be out pixels are zero.

module horizontal_draw (
	input clock_50,
	input [11:0] h_back_porch,
	input [11:0] h_front_porch,
	input [11:0] h_sync_length,
	input [11:0] h_active_pixels,
	input [11:0] h_total_pixels,
	
	output reg h_draw_flag,
	output reg output_flag
);

reg [9:0] horz_pxl = 0;

reg [2:0] currentState, nextState; //3 bit wide regs

parameter HBP = 3'b000; //horizontal back porch
parameter HACTIVE = 3'b001; //horizontal resolution
parameter HFP = 3'b010; //horizontal front porch
parameter HSLEN = 3'b011; //horizontal sync length
parameter RESTART = 3'b100; //restart horizontal draw

//updates the currentState/nextState transition @posedge(stateClock)
always @(posedge(clock_50))
	begin: stateMemory	
		// Update the state variable on the stateClock transition.
		currentState <= nextState;
		
		if(h_draw_flag == 1'b1) begin
				horz_pxl <= horz_pxl + 1'b1;
		end else begin
				horz_pxl <= 1'b0;
		end
	end
	

//handles state transitions
always @(currentState or horz_pxl)
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
	end	
	

endmodule