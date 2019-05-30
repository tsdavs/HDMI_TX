proc runSim {} {
	#clear current sim
	restart -force -nowave

	#add all wf
	add wave *

	
	#set radix of buses
	property wave -radix hex *
	
	#50mhz clock
	force -deposit clock 1 0, 0 {40ps} -repeat 80	
	
	force -freeze MR_n 1
	force -freeze CEP 1
	force -freeze PE_n 1
	#force -freeze start 0


	

	run 50000
	

}

