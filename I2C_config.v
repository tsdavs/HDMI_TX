module I2C_config(
	input reset,
	input clock_25,
	input interrupt,
	
	inout i2c_serial_data,
	
	output i2c_serial_clock
);

wire i2c_serial_data_output; 
wire _stop;
wire _ack; 

reg [23:0] i2c_data;
reg _start = 0;

wire clock_100khz;

counter counter_100khz(
	.MR_n(1'b1),
	.CEP(1'b1),
	.PE_n(1'b1),
	.Dn(),
	.clock(clock_25),
	
	.Qn_out(),
	.TC_out(clock_100khz)
);

I2C_controller I2C_cont(
	//inputs
	.clock_100khz(clock_100khz),
	.register_data(i2c_data[15:0]),
	.slave_address(i2c_data[23:16]),
	.i2c_serial_data_input(i2c_serial_data),
	.start(_start),
	
	//outputs
	.stop(_stop),
	.ack(_ack),
	.i2c_serial_data_output(i2c_serial_data_output),
	.i2c_serial_clock(i2c_serial_clock)
);

reg [5:0] lookup_table_index = 0;
reg [16:0] lookup_table_data;
parameter lookup_table_size = 25; //to include default

reg [2:0] currentState = 0;

reg setup = 1;

always @ (posedge(clock_100khz))
	begin
		//if(reset == 0) begin//remove this later
	
			if(setup == 1) begin 
				lookup_table_index <= 0;
				_start <= 1'b0;
				currentState <= 0;
				setup <= 0;
			end else begin
				//if(lookup_table_index <= lookup_table_size) begin
					case(currentState)
						0: 
							begin
								_start <= 1'b1;
								i2c_data <= {8'h72, lookup_table_data};//3-bytes -> [device_address,memory_address,payload]
								currentState <= 1;
							end
						1: 
							begin
								if(_stop == 0) begin
									if(_ack == 0) begin
										currentState <= 2;
									end else begin
										currentState <= 0;
										_start <= 0;
									end
								end
							end
						2: 
							begin
								lookup_table_index = lookup_table_index + 1'b1; //increment
								currentState <= 0;
							end	
						default: 
							begin
								currentState <= 0;
							end	
					endcase
				//end
			end
		//end//reset - remove this later
	end
	
always @(posedge(clock_25))
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
			default: begin lookup_table_data <= 16'h9803; end
		endcase
	end

assign i2c_serial_data = i2c_serial_data_output ? 1'bz : 0; // Tristate control for the I2C SDA pin.

endmodule