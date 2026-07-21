###############################################################################
## Arty S7-25 Constraints for RISC-V CPU
###############################################################################

############################
# Clock
############################
set_property -dict { PACKAGE_PIN R2 IOSTANDARD SSTL135 } [get_ports CLK100MHZ]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} [get_ports CLK100MHZ]

############################
# UART Interface
############################
# Note: Pin directions are from the perspective of your RISC-V CPU
set_property -dict { PACKAGE_PIN V12 IOSTANDARD LVCMOS33 } [get_ports uart_rx]
set_property -dict { PACKAGE_PIN R12 IOSTANDARD LVCMOS33 } [get_ports uart_tx]

############################
# User Switches
############################
set_property -dict { PACKAGE_PIN H14 IOSTANDARD LVCMOS33 } [get_ports {sw[0]}]
set_property -dict { PACKAGE_PIN H18 IOSTANDARD LVCMOS33 } [get_ports {sw[1]}]
set_property -dict { PACKAGE_PIN G18 IOSTANDARD LVCMOS33 } [get_ports {sw[2]}]
set_property -dict { PACKAGE_PIN M5  IOSTANDARD SSTL135 } [get_ports {sw[3]}]

############################
# Push Buttons
############################
set_property -dict { PACKAGE_PIN G15 IOSTANDARD LVCMOS33 } [get_ports {btn[0]}]
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports {btn[1]}]
set_property -dict { PACKAGE_PIN J16 IOSTANDARD LVCMOS33 } [get_ports {btn[2]}]
set_property -dict { PACKAGE_PIN H13 IOSTANDARD LVCMOS33 } [get_ports {btn[3]}]

############################
# User LEDs
############################
set_property -dict { PACKAGE_PIN E18 IOSTANDARD LVCMOS33 } [get_ports {led[2]}]
set_property -dict { PACKAGE_PIN F13 IOSTANDARD LVCMOS33 } [get_ports {led[3]}]
set_property -dict { PACKAGE_PIN E13 IOSTANDARD LVCMOS33 } [get_ports {led[4]}]
set_property -dict { PACKAGE_PIN H15 IOSTANDARD LVCMOS33 } [get_ports {led[5]}]

############################
# Configuration
############################
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

set_property INTERNAL_VREF 0.675 [get_iobanks 34]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]