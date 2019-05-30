proc runSim {} {
	#clear current sim
	restart -force -nowave

	#add all wf
	add wave *

	
	#set radix of buses
	property wave -radix hex *
	
	#50mhz clock
	force -deposit _clock_50 1 0, 0 {20ps} -repeat 40	
	
	force -deposit HDMI_TX_CLK 1 0, 0 {40ps} -repeat 80	
	
	force -freeze key1 0

	run 31000000
	
	
	

}
