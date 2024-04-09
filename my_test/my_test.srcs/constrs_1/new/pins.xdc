#InPins - System Clock
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports i_clk_p]
set_property -dict {PACKAGE_PIN C19 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports i_clk_n]
# InPins - User button
set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS25} [get_ports i_rst[0]]
set_property -dict {PACKAGE_PIN F19 IOSTANDARD LVCMOS25} [get_ports i_rst[1]]
# OutPins - Led
set_property -dict {PACKAGE_PIN E15 IOSTANDARD LVCMOS25} [get_ports {o_led1[0]}]
set_property -dict {PACKAGE_PIN D15 IOSTANDARD LVCMOS25} [get_ports {o_led1[1]}]
set_property -dict {PACKAGE_PIN W17 IOSTANDARD LVCMOS25} [get_ports {o_led1[2]}]
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS25} [get_ports {o_led1[3]}]
set_property -dict {PACKAGE_PIN V7 IOSTANDARD LVCMOS25} [get_ports {o_led2[4]}]
set_property -dict {PACKAGE_PIN W10 IOSTANDARD LVCMOS25} [get_ports {o_led2[5]}]
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS25} [get_ports {o_led2[6]}]
set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS25} [get_ports {o_led2[7]}]


