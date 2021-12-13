#!/bin/bash

top_module = cpu
test_bench = tb_main

xilinx_sim_time = 1000us

memory_size = 65536

dir_current = $(shell pwd)
dir_output  = $(dir_current)/output

dir_hw = $(dir_current)/hardware/core1

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
	
simulate_hw : verilog_update_simulation compile_hw compile_tb
	@echo "run $(xilinx_sim_time)"  > xilinx_simulation.tcl
	@echo "exit"                   >> xilinx_simulation.tcl
	@xelab -debug typical $(test_bench) -s $(test_bench) -timescale 1ns/1ns -nolog
	@xsim $(test_bench) -t xilinx_simulation.tcl
	# @make verilog_update_synthesis
	@make clean

simulate_gui : verilog_update_simulation compile_hw compile_tb
	@xelab -debug typical $(test_bench) -s $(test_bench) -timescale 1ns/1ps -nolog
	@xsim $(test_bench) -g --nolog
	@make clean
	
verilog_update_simulation:
	@for file in $(file_list_hw) ; do \
		python ./scripts/python/verilog_update.py fwrite_enable $$file ; \
		echo "----------------- fwrite_enable : $$file" ; \
		python ./scripts/python/verilog_update.py hex_enable $$file ; \
		echo "----------------- hex_enable    : $$file" ; \
	done
	@echo -e "\n ------------------\e[1;32m Enabled initial and fwrite for simulation \e[0m----------------------- \n"
	
verilog_update_synthesis:
	@for file in $(file_list_hw) ; do \
		python ./scripts/python/verilog_update.py fwrite_disable $$file ; \
		python ./scripts/python/verilog_update.py hex_disable $$file ; \
	done
	@echo -e "\n ------------------\e[1;31m Disabled initial and fwrite for synthesis \e[0m----------------------- \n"
	
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
	
compile_c :
	riscv32-unknown-elf-gcc $(flag1) $(flag_arch) -T $(linker_script) -I software/library software/test/hello.c -o code.out
	@make fwrite_dump_hex
	
compile_assembly :
	riscv32-unknown-elf-gcc $(flag1) $(flag_arch) -T $(linker_script) software/test/sample.s -o code.out
	@make fwrite_dump_hex

simulate_sw :
	@cp -f ./memory.hex output/ 
	@python ./scripts/python/core_sw.py
	@make clean
	
clean : 
	@rm -rf *.tcl *.pb *.wdb *.jou *.log
	@rm -rf scripts/python/*.pyc
	@rm -rf xsim.dir
	@rm -rf .Xil
	
compare_hw_and_sw :
	@if diff "./output/reg_status_hw.txt" "./output/reg_status_sw.txt" ; \
		then make print_success; \
	else make print_failure; fi
	
print_success:
	@echo -e "\e[1;32m"
	@echo "  *******************************************************************"
	@echo "  **                                          *************        **"
	@echo "  **                                ***     **             **      **"
	@echo "  **                               *   *  **     **   **     **    **"
	@echo "  **    Software and Hardware       * *   **                 **    **"
	@echo "  **        results are           ******* **    *       *    **    **"
	@echo "  **          MATCHING           *   *******     *******     **    **"
	@echo "  **                             *   *****  **             **      **"
	@echo "  **                              *******     *************        **"
	@echo "  *******************************************************************"
	@echo -e "\e[0m"
	
print_failure:
	@echo -e "\e[1;31m"
	@echo "  *******************************************************************"
	@echo "  **                                          *************        **"
	@echo "  **                              *******   **             **      **"
	@echo "  **                             *   *******     **   **     **    **"
	@echo "  **    Software and Hardware    *   *******                 **    **"
	@echo "  **        results are           ******* **     *******     **    **"
	@echo "  **        NOT MATCHING            * *   **    *       *    **    **"
	@echo "  **                               *   *    **             **      **"
	@echo "  **                                ***       *************        **"
	@echo "  *******************************************************************"
	@echo -e "\e[0m"
	