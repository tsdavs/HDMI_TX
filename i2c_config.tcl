proc runSim {} {
	#clear current sim
	restart -force -nowave

	#add all wf
	add wave *

	
	#set radix of buses
	property wave -radix hex *
	
	#50mhz clock
	force -deposit clock_25 1 0, 0 {40ps} -repeat 80	
	run 8000
	

}

