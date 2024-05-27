if { [llength [get_cells -quiet u_reset/with_sync.*]] > 0 } {
  set areset_ss "async_cdc.q_sync_stages_reg*/PRE"
  set_false_path -to [get_pins u_reset/with_sync.u_rclk_w_rst_p/$areset_ss]
  set_false_path -to [get_pins u_reset/with_sync.u_wclk_w_rst_p/$areset_ss]
  set_false_path -to [get_pins u_reset/with_sync.u_wclk_r_rst_p/$areset_ss]
  set_false_path -to [get_pins u_reset/with_sync.u_rclk_r_rst_p/$areset_ss]
}

set w_clock [get_clocks -quiet -of [get_ports i_fifo_w_clk_p]]
set r_clock [get_clocks -quiet -of [get_ports i_fifo_r_clk_p]]

set w_clock_period [get_property -quiet -min PERIOD $w_clock]
set r_clock_period [get_property -quiet -min PERIOD $r_clock]

if { $w_clock == "" } {
  set w_clock_period 1.125
}

if { $r_clock == "" } {
  set r_clock_period 1.375
}

if { [llength [get_cells -quiet u_control/dual_clock.*]] > 0 } {
  set dual_clock_mode "True"
} else {
  set dual_clock_mode "False"
}

if { $dual_clock_mode && ( ($w_clock != $r_clock) || ($w_clock == "" && $r_clock == "") ) } { 
  
  set src_reg "src_with_reg.q_src_cdc_sig_reg[*]"
  set gray_ss "gray_cdc.q_sync_stages_reg[0][*]"

  set cdc_wr_addr "u_control/dual_clock.u_cdc_wr_addr"
  set_max_delay -from [get_cells $cdc_wr_addr/$src_reg] -to [get_cells $cdc_wr_addr/$gray_ss] $w_clock_period -datapath_only
  set_bus_skew  -from [get_cells $cdc_wr_addr/$src_reg] -to [get_cells $cdc_wr_addr/$gray_ss] [expr min($w_clock_period, $r_clock_period)]

  set cdc_rd_addr "u_control/dual_clock.u_cdc_rd_addr"
  set_max_delay -from [get_cells $cdc_rd_addr/$src_reg] -to [get_cells $cdc_rd_addr/$gray_ss] $r_clock_period -datapath_only
  set_bus_skew  -from [get_cells $cdc_rd_addr/$src_reg] -to [get_cells $cdc_rd_addr/$gray_ss] [expr min($w_clock_period, $r_clock_period)]
  
  if { [llength [get_cells -quiet -hier * -filter {PRIMITIVE_SUBGROUP==LUTRAM || PRIMITIVE_SUBGROUP==dram}]] > 0 } {
    set_false_path -to [get_pins u_ram/rd_norm.q_fifo_r_value_reg[0][*]/D]
  }

  set cdc_w_count "u_control/features.u_program/dual_clock.fwft_mode.u_cdc_w_count"
  if { [llength [get_cells -quiet $cdc_w_count]] > 0 } {
    set_max_delay -from [get_cells $cdc_w_count/$src_reg] -to [get_cells $cdc_w_count/$gray_ss] $w_clock_period -datapath_only
    set_bus_skew  -from [get_cells $cdc_w_count/$src_reg] -to [get_cells $cdc_w_count/$gray_ss] [expr min($w_clock_period, $r_clock_period)]
  }

  set cdc_r_count "u_control/features.u_program/dual_clock.fwft_mode.u_cdc_r_count"
  if { [llength [get_cells -quiet $cdc_r_count]] > 0 } {
    set_max_delay -from [get_cells $cdc_r_count/$src_reg] -to [get_cells $cdc_r_count/$gray_ss] $r_clock_period -datapath_only
    set_bus_skew  -from [get_cells $cdc_r_count/$src_reg] -to [get_cells $cdc_r_count/$gray_ss] [expr min($w_clock_period, $r_clock_period)]
  }
} 

if { !$dual_clock_mode && [llength [get_cells -quiet -hier * -filter {PRIMITIVE_SUBGROUP==BRAM}]] > 0 } {
  set_property WRITE_MODE_A NO_CHANGE [get_cells u_ram/wr_norm.q_fifo_ram_mem_reg* -filter {PRIMITIVE_SUBGROUP==BRAM}]
  set_property WRITE_MODE_B NO_CHANGE [get_cells u_ram/wr_norm.q_fifo_ram_mem_reg* -filter {PRIMITIVE_SUBGROUP==BRAM}]   
}

if { $dual_clock_mode && ($w_clock == $r_clock) && $w_clock != "" && $r_clock != "" } {
  common::send_msg_id "FIFO-1" "CRITICAL WARNING" "Write and read clocks are the same.\n   Instance: [current_instance .]\nThis will add unnecessary latency to the design."
}

if { $dual_clock_mode && $w_clock == "" } {
  common::send_msg_id "FIFO-2" "CRITICAL WARNING" "Write clock are not set.\n   Instance: [current_instance .]\nThis can lead to unpredictable results."
}

if { $dual_clock_mode && $r_clock == "" } { 
  common::send_msg_id "FIFO-3" "CRITICAL WARNING" "Read clock are not set.\n   Instance: [current_instance .]\nThis can lead to unpredictable results."
}