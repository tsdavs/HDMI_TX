proc runSim {} {
	#clear current sim
	restart -force -nowave

	#add all wf
	add wave *

	
	#set radix of buses
	property wave -radix hex *
	
	#100khz clock
	force -deposit clock_100khz 1 0, 0 {5000ps} -repeat 10000	
	
	force -freeze register_data 16'h0100
	force -freeze slave_address 8'h72
	force -freeze i2c_serial_data_input 1
	#force -freeze start 0


	

	run 5000000
	

}

