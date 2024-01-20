onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {AMBA IF}
add wave -noupdate -group AW /tb/uu_amba_axi4_lite_if/AW/VALID
add wave -noupdate -group AW /tb/uu_amba_axi4_lite_if/AW/READY
add wave -noupdate -group AW /tb/uu_amba_axi4_lite_if/AW/ADDR
add wave -noupdate -group AW /tb/uu_amba_axi4_lite_if/AW/PROT
add wave -noupdate -group W /tb/uu_amba_axi4_lite_if/W/VALID
add wave -noupdate -group W /tb/uu_amba_axi4_lite_if/W/READY
add wave -noupdate -group W /tb/uu_amba_axi4_lite_if/W/DATA
add wave -noupdate -group W /tb/uu_amba_axi4_lite_if/W/STRB
add wave -noupdate -group B /tb/uu_amba_axi4_lite_if/B/VALID
add wave -noupdate -group B /tb/uu_amba_axi4_lite_if/B/READY
add wave -noupdate -group B /tb/uu_amba_axi4_lite_if/B/RESP
add wave -noupdate -group AR /tb/uu_amba_axi4_lite_if/AR/VALID
add wave -noupdate -group AR /tb/uu_amba_axi4_lite_if/AR/READY
add wave -noupdate -group AR /tb/uu_amba_axi4_lite_if/AR/ADDR
add wave -noupdate -group AR /tb/uu_amba_axi4_lite_if/AR/PROT
add wave -noupdate -group R /tb/uu_amba_axi4_lite_if/R/VALID
add wave -noupdate -group R /tb/uu_amba_axi4_lite_if/R/READY
add wave -noupdate -group R /tb/uu_amba_axi4_lite_if/R/DATA
add wave -noupdate -group R /tb/uu_amba_axi4_lite_if/R/RESP
add wave -noupdate -divider Modules
add wave -noupdate -group AMBA /tb/uu_amba_axi4_lite/i_is_busy
add wave -noupdate -group AMBA /tb/uu_amba_axi4_lite/o_en_amba_write
add wave -noupdate -group AMBA /tb/uu_amba_axi4_lite/o_data_wc
add wave -noupdate -group AMBA /tb/uu_amba_axi4_lite/o_addr_wc
add wave -noupdate -group AMBA /tb/uu_amba_axi4_lite/o_strb
add wave -noupdate -group AMBA /tb/uu_amba_axi4_lite/i_data_rc
add wave -noupdate -group AMBA /tb/uu_amba_axi4_lite/o_addr_rc
add wave -noupdate -group AMBA /tb/uu_amba_axi4_lite/STATE_wc
add wave -noupdate -group AMBA /tb/uu_amba_axi4_lite/STATE_rc
add wave -noupdate -group AMBA /tb/uu_amba_axi4_lite/read_AWADDR
add wave -noupdate -group AMBA /tb/uu_amba_axi4_lite/read_WDATA
add wave -noupdate -group AMBA /tb/uu_amba_axi4_lite/read_WSTRB
add wave -noupdate -group AMBA /tb/uu_amba_axi4_lite/w_en_amba_write_wc
add wave -noupdate -group AMBA /tb/uu_amba_axi4_lite/w_is_busy_wc
add wave -noupdate -group AMBA /tb/uu_amba_axi4_lite/read_ARPROT
add wave -noupdate -group AMBA /tb/uu_amba_axi4_lite/read_ARADDR
add wave -noupdate -group AMBA /tb/uu_amba_axi4_lite/read_RDATA
add wave -noupdate -group AMBA /tb/uu_amba_axi4_lite/w_is_busy_rc
add wave -noupdate -group RegFile /tb/uu_regfile/ACLK
add wave -noupdate -group RegFile /tb/uu_regfile/ARSTn
add wave -noupdate -group RegFile /tb/uu_regfile/i_addr_wc
add wave -noupdate -group RegFile /tb/uu_regfile/i_data_wc
add wave -noupdate -group RegFile /tb/uu_regfile/i_addr_rc
add wave -noupdate -group RegFile /tb/uu_regfile/o_data_rc
add wave -noupdate -group RegFile /tb/uu_regfile/i_en_amba_write
add wave -noupdate -group RegFile /tb/uu_regfile/i_enable_ctrl_write
add wave -noupdate -group RegFile /tb/uu_regfile/o_start
add wave -noupdate -group RegFile /tb/uu_regfile/i_busr
add wave -noupdate -group RegFile /tb/uu_regfile/o_r0
add wave -noupdate -group RegFile /tb/uu_regfile/o_r1
add wave -noupdate -group RegFile /tb/uu_regfile/register
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {2600 ns}
