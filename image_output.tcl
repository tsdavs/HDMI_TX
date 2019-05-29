proc runSim {} {
	#clear current sim
	restart -force -nowave

	#add all wf
	add wave *
	
	#set radix of buses
	property wave -radix hex *
	
	#50mhz clock
	force -deposit pixel_clock 1 0, 0 {40ps} -repeat 80	

	force -freeze _draw_flag 1

	run 31000000
	

}