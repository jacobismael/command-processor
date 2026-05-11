# Rebuild Vivado project from source
# Run with:
# vivado -mode batch -source scripts/build.tcl

set project_name "final"
set part_name "xc7a100tcsg324-1"
set board_part "digilentinc.com:nexys-a7-100t:part0:1.3"

set repo_dir [file normalize [file join [file dirname [info script]] ".."]]
set build_dir [file join $repo_dir "build"]

file mkdir $build_dir

create_project $project_name $build_dir -part $part_name -force

# Set board part for Nexys A7-100T
set_property board_part $board_part [current_project]

# Add handwritten HDL files
set hdl_files [glob -nocomplain $repo_dir/src/hdl/*.v]
if {[llength $hdl_files] > 0} {
    add_files -fileset sources_1 $hdl_files
}

# Add simulation files
set sim_files [glob -nocomplain $repo_dir/src/sim/*.v]
if {[llength $sim_files] > 0} {
    add_files -fileset sim_1 $sim_files
    set_property top cpm_tb [get_filesets sim_1]
}

# Add constraints, if present
set xdc_files [glob -nocomplain $repo_dir/constraints/*.xdc]
if {[llength $xdc_files] > 0} {
    add_files -fileset constrs_1 $xdc_files
}

# Recreate block design
source $repo_dir/scripts/cpm_bd.tcl

# Get the block design file
set bd_file [get_files *cpm_bd.bd]

# Save and validate the block design
validate_bd_design
save_bd_design

# Generate block design output products
generate_target all $bd_file

# Generate the HDL wrapper from the block design
make_wrapper -files $bd_file -top

# Add generated wrapper
set wrapper_file [glob -nocomplain $build_dir/${project_name}.gen/sources_1/bd/cpm_bd/hdl/cpm_bd_wrapper.v]

if {[llength $wrapper_file] == 0} {
    puts "ERROR: Could not find generated cpm_bd_wrapper.v"
    exit 1
}

add_files -norecurse $wrapper_file

# Set top module
set_property top cpm_top [get_filesets sources_1]

# Update compile order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "Project rebuilt successfully."
puts "Open with: vivado $build_dir/$project_name.xpr"
