proc runSim {} {
	#clear current sim
	restart -force -nowave

	#add all wf
	add wave clock_25
	add wave h_count_flag
	add wave draw_flag
	add wave vert_pxl
	add wave horz_pxl
	add wave h_sync
	add wave v_sync

	
	#set radix of buses
	property wave -radix hex *
	
	#50mhz clock
	force -deposit clock_25 1 0, 0 {40ps} -repeat 80	
	
	force -freeze v_back_porch 12'd32;
	force -freeze v_front_porch 12'd9;
	force -freeze v_sync_length 12'd1;
	force -freeze v_active_pixels 12'd479;
	force -freeze v_total_pixels 12'd524;
	
	force -freeze h_back_porch 12'd47;
	force -freeze h_front_porch 12'd15;
	force -freeze h_sync_length 12'd95;
	force -freeze h_active_pixels 12'd639;
	force -freeze h_total_pixels 12'd799;

	#view vsync
	run 31000000

	#view hsync
	#run 80000
	

}