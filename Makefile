#!/bin/bash

top_module = cpu
test_bench = tb_main

xilinx_sim_time = 4000us

memory_size = 65536

file_list_all = $(shell find $(dir_hw) -name *.v ! -name tb*.v )
file_list_tb  = $(shell find $(dir_hw) -name *tb*.v )
file_list_hw  = $(filter-out $(file_list_tb),$(file_list_all))


compile_hw :
	@xvlog $(file_list_hw)
	
compile_tb :
	@if [ "$(file_list_tb)" != "" ]; then \
		xvlog $(file_list_tb) ;\
	else \
		echo -e "\n ------------------\e[1;34m No tb file \e[0m----------------------- \n" ;\
	fi
	
simulate_hw : compile_hw compile_tb
	@echo "run $(xilinx_sim_time)"  > xilinx_simulation.tcl
	@echo "exit"                   >> xilinx_simulation.tcl
	@xelab -debug typical $(test_bench) -s $(test_bench) -timescale 1ns/1ns -nolog
	@xsim $(test_bench) -t xilinx_simulation.tcl
	# @make update_memory
	@make clean

simulate_gui : compile_hw compile_tb
	@xelab -debug typical $(test_bench) -s $(test_bench) -timescale 1ns/1ps -nolog
	@xsim $(test_bench) -g --nolog
	@make clean
	
	
fwrite_dump_hex :
	@riscv32-unknown-elf-objdump -d code.out > code.out.dump
	@elf2hex 4 $(memory_size) code.out > memory.hex
	@make clean	

flag_arch = -march=rv32im -mabi=ilp32
flag1 = -static -O3 -fno-inline -mcmodel=medany -fvisibility=hidden
flag2 = -O3 -g -falign-functions=16 -funroll-all-loops

linker_script = software/bare-metal.ld

compile_dhry2.1 :
	riscv32-unknown-elf-gcc $(flag1) $(flag_arch) -T $(linker_script) software/dhry2.1/dhrystone.c -o code.out
	@make fwrite_dump_hex

clean : 
	@rm -rf *.tcl *.pb *.wdb *.jou *.log
	@rm -rf xsim.dir
	@rm -rf .Xil
	
	
	