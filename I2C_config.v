module I2C_config(
	input clock_50,
	input interrupt,
	
	inout i2c_serial_data,
	
	output i2c_serial_clock
);

wire i2c_serial_data_output; 

reg [23:0] i2c_data;

I2C_controller I2C_cont(
	//inputs
	.clock_50(clock_50),
	.register_data(i2c_data[15:0]),
	.slave_address(i2c_data[23:16]),
	.i2c_serial_data_input(i2c_serial_data),
	
	//outputs
	.i2c_serial_data_output(i2c_serial_data_output),
	.i2c_serial_clock(i2c_serial_clock)
);

reg [5:0] lookup_table_index = 0;
reg [16:0] lookup_table_data;
parameter lookup_table_size = 24;

always @ (posedge(clock_50))
	begin
		if(lookup_table_index < lookup_table_size) begin
			i2c_data <= {8'h72,lookup_table_data};//[SLAVE_ADDR,SUB_ADDR,DATA]
			lookup_table_index = lookup_table_index + 1'b1; //increment
		end
	end
	
always @(posedge(clock_50))
	begin
		case(lookup_table_index)
			0: lookup_table_data <= 16'h0100; //Set N Value (6144)
			1: lookup_table_data <= 16'h0218; //Set N Value (6144)
			2: lookup_table_data <= 16'h0300; //Set N Value (6144)
			3: lookup_table_data <= 16'h1500; //Input 444 (RGB or YCrCb) with separate syncs
			4: lookup_table_data <= 16'h1661; //44.1kHz fs, YPrPb 444
			5: lookup_table_data <= 16'h1846; //CSC disabled
			6: lookup_table_data <= 16'h4080; //General Control Packet Enable
			7: lookup_table_data <= 16'h4110; //Power Down Control
			8: lookup_table_data <= 16'h4848; //Reverse bus, Data right justified
			9: lookup_table_data <= 16'h48a8; //Set Dither_mode - 12-to-10 bit
			10: lookup_table_data <= 16'h4c06; //12 bit Output
			11: lookup_table_data <= 16'h5500; //Set RGB444 in AVinfo Frame
			12: lookup_table_data <= 16'h5508; //Set active format aspect
			13: lookup_table_data <= 16'h9620; //HPD Interrupt clear
			14: lookup_table_data <= 16'h9803; //ADI required write
			15: lookup_table_data <= 16'h9802; //ADI required write
			16: lookup_table_data <= 16'h9c30; //ADI required write
			17: lookup_table_data <= 16'h9d61; //Set clock divide
			18: lookup_table_data <= 16'ha2a4; //ADI required write
			19: lookup_table_data <= 16'ha3a4; //ADI required write
			20: lookup_table_data <= 16'haf16; //Set HDMI Mode
			21: lookup_table_data <= 16'hba60; //No clock delay
			22: lookup_table_data <= 16'hde9c; //ADI required write
			23: lookup_table_data <= 16'he460; //ADI required write
			24: lookup_table_data <= 16'hfa7d; //Nbr of times to search for good phase
			default: begin lookup_table_data <= 16'h0000e; end
		endcase
	end

assign i2c_serial_data = i2c_serial_data_output ? 1'bz : 0; 

endmodule