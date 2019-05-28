proc runSim {} {
	#clear current sim
	restart -force -nowave

	#add all wf
	add wave *

	
	#set radix of buses
	property wave -radix hex *
	
	#50mhz clock
	force -deposit _clock_50 1 0, 0 {20ps} -repeat 40	
	
	run 80000
	
	
	

}
