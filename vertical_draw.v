//vertical draw counter state machine that draws
//depending on front port/ back porch etc.
//v_d controls the horizontal draw when it should draw
//if no data should be out pixels are zero.

//ref: https://www.digi.com/resources/documentation/digidocs/90001945-13/reference/yocto/r_an_adding_custom_display.htm

module vertical_draw (
	input clock


)


reg [1:0] currentState, nextState; //2 bit wide regs

parameter VBP = 2'b00; //vertical back porch
parameter VACTIVE = 2'b01; //vertical resolution
parameter VFP = 2'b10; //vertical front porch
parameter VSLEN = 2'b11; //vertical sync length

//updates the currentState/nextState transition @posedge(stateClock)
always @(posedge(clock))
	begin: stateMemory	
		// Update the state variable on the stateClock transition.
		currentState <= nextState;
	end
	
//handles state transitions
always @(currentState)
	begin: nextStateLogic
		case(currentState)
			VBP:
				begin
					nextState = VACTIVE;
				end
			VACTIVE:
				begin
					nextState = VFP;
				end
			VFP:
				begin
					nextState = VSLEN;
				end
			VSLEN:
				begin
					nextState = VBP;
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
				end
			VACTIVE:
				begin
					//start drawing horizontal
				end
			VFP:
				begin
				end
			VSLEN:
				begin
				end
			default:
				begin
				end
			endcase
	end	
	
endmodule;