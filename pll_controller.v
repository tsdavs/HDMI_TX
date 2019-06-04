module pll_controller (
	input							clk,
	input							reset_n,
	input				[31:0]	mgmt_readdata,
	output	reg				mgmt_read,
	output	reg				mgmt_write,
	output	reg	[5:0]		mgmt_address,
	output	reg	[31:0]	mgmt_writedata
);

//=======================================================
//  Signal declarations
//=======================================================
reg	[17:0]	m_counter, n_counter, c_counter;
reg	[1:0]		write_count;
reg	[3:0]		state;

//=======================================================
//  Structural coding
//=======================================================
always@(posedge clk or negedge reset_n)
begin
	if (!reset_n)
	begin
		//mode_change_d <= 3'b0;
		state <= 4'h0;
		write_count <= 2'b0;
		mgmt_read <= 1'b0;
		mgmt_write <= 1'b0;
	end
	else
	begin  	
	case (state)
		4'h0 : begin //idle		  	 
				state <=4'h1;
	         mgmt_address <= 6'h0; //polling mode
	         mgmt_writedata <= 32'h1;
			end
		4'h1 : begin //polling mode
			if (write_count == 2'b0)
				mgmt_write <= 1'b1;
			else
				mgmt_write <= 1'b0;

				if (write_count[1])
				begin
					write_count <= 2'b0;
					state <=4'h2;
					mgmt_address <= 6'h4; //m_counter
					mgmt_writedata <= {14'h0, 18'h1_00_00};//m_counter
				end
				else
					write_count <= write_count+2'b1;
			end	
		4'h2 : begin //m_counter
			if (write_count == 2'b0)
				mgmt_write <= 1'b1;
			else
				mgmt_write <= 1'b0;

				if (write_count[1])
				begin
					write_count <= 2'b0;
					state <=4'h3;
					mgmt_address <= 6'h3; //n_counter
					mgmt_writedata <= {14'h0, 18'h1_00_00};//n_counter
				end
				else
					write_count <= write_count+2'b1;
			end	
		4'h3 : begin //n_counter
			if (write_count == 2'b0)
				mgmt_write <= 1'b1;
			else
				mgmt_write <= 1'b0;

				if (write_count[1])
				begin
					write_count <= 2'b0;
					state <=4'h4;
					mgmt_address <= 6'h5; //c_counter
					mgmt_writedata <= {14'h0, 18'h0_01_01};//c_counter
				end
				else
					write_count <= write_count+2'b1;
			end	
		4'h4 : begin //c_counter
			if (write_count == 2'b0)
				mgmt_write <= 1'b1;
			else
				mgmt_write <= 1'b0;

				if (write_count[1])
				begin
					write_count <= 2'b0;
					state <=4'h5;
					mgmt_address <= 6'h8; //bandwidth
					mgmt_writedata <= 32'h6; //medium
				end
				else
					write_count <= write_count+2'b1;
			end	
		4'h5 : begin //bandwidth
			if (write_count == 2'b0)
				mgmt_write <= 1'b1;
			else
				mgmt_write <= 1'b0;

				if (write_count[1])
				begin
					write_count <= 2'b0;
					state <=4'h6;
					mgmt_address <= 6'h9; //charge pump
					mgmt_writedata <= 32'h3; //medium
				end
				else
					write_count <= write_count+2'b1;
			end	
		4'h6 : begin //charge pump
			if (write_count == 2'b0)
				mgmt_write <= 1'b1;
			else
				mgmt_write <= 1'b0;

				if (write_count[1])
				begin
					write_count <= 2'b0;
					state <=4'h7;
					mgmt_address <= 6'h2; //start reconfig
					mgmt_writedata <= 32'h1;
				end
				else
					write_count <= write_count+2'b1;
			end	
		4'h7 : begin //start reconfig
			if (write_count == 2'b0)
				mgmt_write <= 1'b1;
			else
				mgmt_write <= 1'b0;

				if (write_count[1])
				begin
					write_count <= 2'b0;
					state <=4'h8;
					mgmt_address <= 6'h1; //status check
				end
				else
					write_count <= write_count+2'b1;
			end	
		4'h8 : begin //status check
			if (mgmt_read && mgmt_readdata[0])
			begin
				mgmt_read <= 1'b0;
				state <=4'h0;
			end
			else
				mgmt_read <= 1'b1;
			end	
	endcase
	end	
end

endmodule