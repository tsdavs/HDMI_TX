//Design parameterised-bit optimised counter

module counter #(parameter width = 8)
(
	input MR_n, //master reset
	input CEP,
	input PE_n, //load
	input [width-1:0] Dn,
	input clock,
	
	output [width-1:0] Qn_out,
	output reg TC_out
);

//Register variable used to store the current count value
reg [width-1:0] counterValue = 0;

//count on the main sysClock
always @(posedge(clock))
	begin
		//check reset condition
		if(MR_n == 1'b0)
			begin
				//set the counter back to zero
				counterValue = 0;
			end
		else if(PE_n == 1'b0)
			begin
				//parallel load requested
				counterValue = Dn;
			end
		else if(CEP == 1'b1)
			begin
				if(counterValue ==  8'b11111010)
					begin
						//sets wrap around for overflow
						TC_out = 1;
						counterValue = 0;
					end
				else
					begin
					//the counter is enabled, so increment by 1
					counterValue = counterValue + 1'b1;
					TC_out = 0;
					end
			end
		else
			begin
				//hold condition
				counterValue = counterValue;
			end
	end
	
//final assignment
assign Qn_out = counterValue;
//assign TC_out = &counterValue;

endmodule