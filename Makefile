# Project
PROJECT = FIZZ_BUZZ
# Directory
PLD_DIR = ./pld
PRG_DIR = ./output_files
TB_DIR = ./testbench

PRG = $(PRG_DIR)/$(PROJECT).sof
TB_SRC = $(TB_DIR)/TB_$(PROJECT).sv

MODELSIM_LIB_FLAGS = -work work
MODELSIM_SIM_FLAGS = -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"
MODELSIM_DO_FLAGS = -do "add wave -hex *; \
					add wave -hex U_FIZZ_BUZZ/product_3i; \
					add wave -hex U_FIZZ_BUZZ/product_5i; \
					view structure; \
					view signals; \
					run -all; \
					quit"


lib_exist := $(shell find -maxdepth 1 -name rtl_work -type d)

all: $(PRG) check

$(PRG) : $(PLD_DIR)/*.vhd
	quartus_sh.exe --flow compile $(PROJECT)

check: ./rtl_work/
	vmap.exe work rtl_work
#	vcom.exe -93 $(MODELSIM_LIB_FLAGS) $(PLD_DIR)/PAC_*.vhd
	vcom.exe -93 $(MODELSIM_LIB_FLAGS) $(PLD_DIR)/*.vhd
	vlog.exe -sv $(MODELSIM_LIB_FLAGS) +incdir+$(TB_DIR) $(TB_SRC)
	vsim.exe -c $(MODELSIM_SIM_FLAGS) -msgmode both -displaymsgmode both TB_$(PROJECT) $(MODELSIM_DO_FLAGS)

./rtl_work/: $(TB_SRC)
	$(if $(lib_exist),vdel.exe -lib rtl_work -all)
	vlib.exe rtl_work

.PHONY: all check