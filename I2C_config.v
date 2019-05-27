module I2C_config(
	input clock_50,
	input interrupt,
	
	inout i2c_serial_data,
	
	output i2c_serial_clock
);

reg [23:0] i2c_data;


reg [5:0] lookup_table_index;
reg [16:0] lookup_table_data;

always @ (posedge clock_50)
	begin
		i2c_data <= {8'h72,lookup_table_data}
		
	
	end

always
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
			default: begin end
		endcase
	end



endmodule