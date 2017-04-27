# TCL File Generated by Component Editor 16.0
# Thu Apr 27 18:34:33 CEST 2017
# DO NOT MODIFY


# 
# mm_raytracing "mm_raytracing" v1.0
#  2017.04.27.18:34:33
# 
# 

# 
# request TCL package from ACDS 16.0
# 
package require -exact qsys 16.0


# 
# module mm_raytracing
# 
set_module_property DESCRIPTION ""
set_module_property NAME mm_raytracing
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME mm_raytracing
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL raytracing_mm
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file anyRefl.vhd VHDL PATH ../vhdl/components/anyRefl.vhd
add_fileset_file backend.vhd VHDL PATH ../vhdl/components/backend.vhd
add_fileset_file closestSphere.vhd VHDL PATH ../vhdl/components/closestSphere.vhd
add_fileset_file closestSphereNew.vhd VHDL PATH ../vhdl/components/closestSphereNew.vhd
add_fileset_file closestSpherePrep.vhd VHDL PATH ../vhdl/components/closestSpherePrep.vhd
add_fileset_file colorUpdate.vhd VHDL PATH ../vhdl/components/colorUpdate.vhd
add_fileset_file components_pkg.vhd VHDL PATH ../vhdl/components/components_pkg.vhd
add_fileset_file delay.vhd VHDL PATH ../vhdl/components/delay.vhd
add_fileset_file delay_pkg.vhd VHDL PATH ../vhdl/components/delay_pkg.vhd
add_fileset_file getRayDir.vhd VHDL PATH ../vhdl/components/getRayDir.vhd
add_fileset_file getRayDirAlt.vhd VHDL PATH ../vhdl/components/getRayDirAlt.vhd
add_fileset_file getRayDirOpt.vhd VHDL PATH ../vhdl/components/getRayDirOpt.vhd
add_fileset_file lfsr.vhd VHDL PATH ../vhdl/components/lfsr.vhd
add_fileset_file lpm_util.vhd VHDL PATH ../vhdl/components/lpm_util.vhd
add_fileset_file math_pkg.vhd VHDL PATH ../vhdl/components/math_pkg.vhd
add_fileset_file operations_pkg.vhd VHDL PATH ../vhdl/components/operations_pkg.vhd
add_fileset_file picture_data.vhd VHDL PATH ../vhdl/components/picture_data.vhd
add_fileset_file rayDelay.vhd VHDL PATH ../vhdl/components/rayDelay.vhd
add_fileset_file rayDelay_pkg.vhd VHDL PATH ../vhdl/components/rayDelay_pkg.vhd
add_fileset_file raytracing_mm.vhd VHDL PATH ../vhdl/components/raytracing_mm.vhd TOP_LEVEL_FILE
add_fileset_file readInterface.vhd VHDL PATH ../vhdl/components/readInterface.vhd
add_fileset_file reflect.vhd VHDL PATH ../vhdl/components/reflect.vhd
add_fileset_file scalarMul.vhd VHDL PATH ../vhdl/components/scalarMul.vhd
add_fileset_file sphereDistance.vhd VHDL PATH ../vhdl/components/sphereDistance.vhd
add_fileset_file sqrt.vhd VHDL PATH ../vhdl/components/sqrt.vhd
add_fileset_file vecMulS.vhd VHDL PATH ../vhdl/components/vecMulS.vhd
add_fileset_file vector_add_sub.vhd VHDL PATH ../vhdl/components/vector_add_sub.vhd
add_fileset_file vector_dot.vhd VHDL PATH ../vhdl/components/vector_dot.vhd
add_fileset_file vector_square.vhd VHDL PATH ../vhdl/components/vector_square.vhd
add_fileset_file writeInterface.vhd VHDL PATH ../vhdl/components/writeInterface.vhd
add_fileset_file add.vhd VHDL PATH ../vhdl/ip_cores/add.vhd
add_fileset_file add_sub.vhd VHDL PATH ../vhdl/ip_cores/add_sub.vhd
add_fileset_file compare.vhd VHDL PATH ../vhdl/ip_cores/compare.vhd
add_fileset_file mult.vhd VHDL PATH ../vhdl/ip_cores/mult.vhd
add_fileset_file square.vhd VHDL PATH ../vhdl/ip_cores/square.vhd
add_fileset_file sr_ram.vhd VHDL PATH ../vhdl/ip_cores/sr_ram.vhd
add_fileset_file sub.vhd VHDL PATH ../vhdl/ip_cores/sub.vhd
add_fileset_file alt_fwft_fifo.vhd VHDL PATH ../vhdl/components/alt_fwft_fifo.vhd


# 
# parameters
# 


# 
# display items
# 


# 
# connection point clock_sink
# 
add_interface clock_sink clock end
set_interface_property clock_sink clockRate 0
set_interface_property clock_sink ENABLED true
set_interface_property clock_sink EXPORT_OF ""
set_interface_property clock_sink PORT_NAME_MAP ""
set_interface_property clock_sink CMSIS_SVD_VARIABLES ""
set_interface_property clock_sink SVD_ADDRESS_GROUP ""

add_interface_port clock_sink clk clk Input 1


# 
# connection point reset_sink
# 
add_interface reset_sink reset end
set_interface_property reset_sink associatedClock clock_sink
set_interface_property reset_sink synchronousEdges DEASSERT
set_interface_property reset_sink ENABLED true
set_interface_property reset_sink EXPORT_OF ""
set_interface_property reset_sink PORT_NAME_MAP ""
set_interface_property reset_sink CMSIS_SVD_VARIABLES ""
set_interface_property reset_sink SVD_ADDRESS_GROUP ""

add_interface_port reset_sink res_n reset Input 1


# 
# connection point mm_nios_slave
# 
add_interface mm_nios_slave avalon end
set_interface_property mm_nios_slave addressUnits WORDS
set_interface_property mm_nios_slave associatedClock clock_sink
set_interface_property mm_nios_slave associatedReset reset_sink
set_interface_property mm_nios_slave bitsPerSymbol 8
set_interface_property mm_nios_slave burstOnBurstBoundariesOnly false
set_interface_property mm_nios_slave burstcountUnits WORDS
set_interface_property mm_nios_slave explicitAddressSpan 0
set_interface_property mm_nios_slave holdTime 0
set_interface_property mm_nios_slave linewrapBursts false
set_interface_property mm_nios_slave maximumPendingReadTransactions 0
set_interface_property mm_nios_slave maximumPendingWriteTransactions 0
set_interface_property mm_nios_slave readLatency 0
set_interface_property mm_nios_slave readWaitTime 1
set_interface_property mm_nios_slave setupTime 0
set_interface_property mm_nios_slave timingUnits Cycles
set_interface_property mm_nios_slave writeWaitTime 0
set_interface_property mm_nios_slave ENABLED true
set_interface_property mm_nios_slave EXPORT_OF ""
set_interface_property mm_nios_slave PORT_NAME_MAP ""
set_interface_property mm_nios_slave CMSIS_SVD_VARIABLES ""
set_interface_property mm_nios_slave SVD_ADDRESS_GROUP ""

add_interface_port mm_nios_slave address address Input 16
add_interface_port mm_nios_slave write write Input 1
add_interface_port mm_nios_slave writedata writedata Input 32
add_interface_port mm_nios_slave read read Input 1
add_interface_port mm_nios_slave readdata readdata Output 32
set_interface_assignment mm_nios_slave embeddedsw.configuration.isFlash 0
set_interface_assignment mm_nios_slave embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment mm_nios_slave embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment mm_nios_slave embeddedsw.configuration.isPrintableDevice 0


# 
# connection point mm_sdram_master
# 
add_interface mm_sdram_master avalon start
set_interface_property mm_sdram_master addressUnits SYMBOLS
set_interface_property mm_sdram_master associatedClock clock_sink
set_interface_property mm_sdram_master associatedReset reset_sink
set_interface_property mm_sdram_master bitsPerSymbol 8
set_interface_property mm_sdram_master burstOnBurstBoundariesOnly false
set_interface_property mm_sdram_master burstcountUnits WORDS
set_interface_property mm_sdram_master doStreamReads false
set_interface_property mm_sdram_master doStreamWrites false
set_interface_property mm_sdram_master holdTime 0
set_interface_property mm_sdram_master linewrapBursts false
set_interface_property mm_sdram_master maximumPendingReadTransactions 0
set_interface_property mm_sdram_master maximumPendingWriteTransactions 0
set_interface_property mm_sdram_master readLatency 0
set_interface_property mm_sdram_master readWaitTime 1
set_interface_property mm_sdram_master setupTime 0
set_interface_property mm_sdram_master timingUnits Cycles
set_interface_property mm_sdram_master writeWaitTime 0
set_interface_property mm_sdram_master ENABLED true
set_interface_property mm_sdram_master EXPORT_OF ""
set_interface_property mm_sdram_master PORT_NAME_MAP ""
set_interface_property mm_sdram_master CMSIS_SVD_VARIABLES ""
set_interface_property mm_sdram_master SVD_ADDRESS_GROUP ""

add_interface_port mm_sdram_master master_address address Output 32
add_interface_port mm_sdram_master master_write write Output 1
add_interface_port mm_sdram_master master_colordata writedata Output 32
add_interface_port mm_sdram_master slave_waitreq waitrequest Input 1


# 
# connection point pixel
# 
add_interface pixel avalon end
set_interface_property pixel addressUnits WORDS
set_interface_property pixel associatedClock clock_sink
set_interface_property pixel associatedReset reset_sink
set_interface_property pixel bitsPerSymbol 8
set_interface_property pixel burstOnBurstBoundariesOnly false
set_interface_property pixel burstcountUnits WORDS
set_interface_property pixel explicitAddressSpan 0
set_interface_property pixel holdTime 0
set_interface_property pixel linewrapBursts false
set_interface_property pixel maximumPendingReadTransactions 0
set_interface_property pixel maximumPendingWriteTransactions 0
set_interface_property pixel readLatency 0
set_interface_property pixel readWaitTime 1
set_interface_property pixel setupTime 0
set_interface_property pixel timingUnits Cycles
set_interface_property pixel writeWaitTime 0
set_interface_property pixel ENABLED true
set_interface_property pixel EXPORT_OF ""
set_interface_property pixel PORT_NAME_MAP ""
set_interface_property pixel CMSIS_SVD_VARIABLES ""
set_interface_property pixel SVD_ADDRESS_GROUP ""

add_interface_port pixel pixel_address address Input 1
add_interface_port pixel pixel_read read Input 1
add_interface_port pixel pixel_readdata readdata Output 32
set_interface_assignment pixel embeddedsw.configuration.isFlash 0
set_interface_assignment pixel embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment pixel embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment pixel embeddedsw.configuration.isPrintableDevice 0

