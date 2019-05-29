proc runSim {} {
	#clear current sim
	restart -force -nowave

	#add all wf
	add wave *

	
	#set radix of buses
	property wave -radix hex *
	
	#50mhz clock
	force -deposit clock_25 1 0, 0 {40ps} -repeat 80	
	
	force -freeze register_data 16'h0100
	force -freeze slave_address 8'h7A 
	force -freeze i2c_serial_data_input 1
	force -freeze start 0


	

	run 10000
	

}

