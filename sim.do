if { [file exists "work"] } {
	vdel -all
}

vlib work
vlog i2c_tb.v i2c_master.v

vsim work.testbench

add wave /testbench/test1/i_clk
add wave /testbench/test1/io_sda
add wave /testbench/test1/serial_Data_out
add wave /testbench/test1/o_scl
add wave /testbench/test1/serial_Data_in
add wave -radix unsigned /testbench/test1/state
add wave -radix unsigned /testbench/test1/count


onbreak resume

run -all

wave zoom full