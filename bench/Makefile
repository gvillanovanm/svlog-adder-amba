# Configuration options: REGFILE, AMBA, MAIN, FPGA
CONFIG_OPTION = FPGA

# Option 1:
ifeq ($(CONFIG_OPTION), REGFILE)
    TB = tb_regfile
    PKG_FILES =
    DUT_FILES = \
        ../svlog/regfile.sv
endif

# Option 2:
ifeq ($(CONFIG_OPTION), AMBA)
    TB = tb_amba
    PKG_FILES = ../svlog/amba_axi4_lite_types_pkg.sv
    DUT_FILES = \
        ../svlog/amba_axi4_lite_if.sv \
        ../svlog/amba_axi4_lite.sv \
		../svlog/regfile.sv
endif

# Option 3:
ifeq ($(CONFIG_OPTION), MAIN)
    TB = tb_top
    PKG_FILES = ../svlog/amba_axi4_lite_types_pkg.sv
    DUT_FILES = \
        ../svlog/amba_axi4_lite_if.sv \
        ../svlog/amba_axi4_lite.sv \
		../svlog/regfile.sv \
		../svlog/datapath.sv \
		../svlog/control.sv \
		../svlog/adder_amba_top.sv
endif

# Option 4:
ifeq ($(CONFIG_OPTION), FPGA)
    TB = tb_top_fpga
    PKG_FILES = 
    DUT_FILES = \
		../svlog/regfile.sv \
		../svlog/datapath.sv \
		../svlog/control.sv \
        ../fpga/amba_axi4_lite.sv \
		../fpga/adder_amba_top.sv \
		../fpga/wrapper_xilinx/svlog_adder_amba_v1_0_S00_AXI.sv \
		../fpga/wrapper_xilinx/svlog_adder_amba_v1_0.sv
endif

run_cds: cds_batchmode
run_questa: questa_batchmode 

# ----------------------------------------------------
# Xrun Cadence
# ----------------------------------------------------
CDS_DATABASE  = -sysv -64 -access rwc 
CDS_DEBUG     = -debug -linedebug -classlinedebug
CDS_COV_FLAGS = -coverage all
CDS_UVM_FLAGS = -uvm +UVM_NO_RELNOTES
CDS_UVM_DEBUG = -uvmlinedebug +UVM_PHASE_TRACE +UVM_OBJECTION_TRACE
CDS_DEFINES   = -define DEF_DUMMY

cds_batchmode: cds_clean
	xrun $(CDS_DATABASE) $(CDS_DEBUG) $(CDS_COV_FLAGS) $(CDS_UVM_FLAGS) $(CDS_UVM_DEBUG) $(DUT_FILES) $(CDS_DEFINES) $(PKG_FILES) $(TB).sv

cds_gui:
	xrun $(CDS_DATABASE) $(CDS_DEBUG) $(CDS_COV_FLAGS) $(CDS_UVM_FLAGS) $(CDS_UVM_DEBUG) $(DUT_FILES) $(CDS_DEFINES) $(PKG_FILES) $(TB).sv -gui

cds_clean:
	rm -rf xcelium.d
	rm -rf xrun.*
	rm -rf .simvision
	rm -rf xmsim*
	rm -rf cov_work
	rm -rf *.vcd

# ----------------------------------------------------
# QuestaSim
# ----------------------------------------------------
QUESTA_LIB_WORK = lib_BENCH

questa_batchmode: questa_clean questa_libs questa_compile
	vsim +nowarn3116 -batch -do "run -all" $(QUESTA_LIB_WORK).tb

questa_gui: questa_clean questa_libs questa_compile
	vsim

questa_compile:
	vlib ../libs/$(QUESTA_LIB_WORK)
	vmap $(QUESTA_LIB_WORK) ../libs/$(QUESTA_LIB_WORK) 
	vlog -work $(QUESTA_LIB_WORK) $(PKG_FILES) $(DUT_FILES) $(TB).sv

questa_libs:
	mkdir -p ../libs/lib_BENCH

questa_clean:
	rm -rf modelsim.ini
	rm -rf transcript
	rm -rf vsim.wlf
	rm -rf ../libs/

# clean
clean: cds_clean questa_clean
