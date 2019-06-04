//Design parameterised-bit optimised counter

module counter #(parameter width = 9)(
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
		if(counterValue ==  9'b111110100) //8'b11111010
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
	
//final assignment
assign Qn_out = counterValue;

endmodule