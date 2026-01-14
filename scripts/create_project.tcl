# create_project.tcl
# Vivado 2024.2+ recommended (project created with Vivado 2024.2)
#
# Usage (from repo root):
#   vivado -mode batch -source scripts/create_project.tcl -tclargs ./_vivado
#
# This will create a Vivado project under ./_vivado/digital_oscilloscope_basys3

set out_dir [lindex $argv 0]
if { $out_dir eq "" } {
  set out_dir "./_vivado"
}

set repo_root [file normalize [file dirname [info script]]/..]
set proj_name "digital_oscilloscope_basys3"
set proj_dir [file normalize "$out_dir/$proj_name"]

file mkdir $out_dir

create_project $proj_name $proj_dir -part xc7a35tcpg236-1 -force
set_property target_language VHDL [current_project]

# Add HDL sources
set src_dir [file normalize "$repo_root/src"]
set src_files [glob -nocomplain -directory $src_dir *.vhd *.vhdl]
add_files -fileset sources_1 $src_files

# Add constraints
set xdc_file [file normalize "$repo_root/constraints/constraints.xdc"]
add_files -fileset constrs_1 $xdc_file

# Add IP configuration (XCI)
set ip_dir [file normalize "$repo_root/ip"]
set ip_files [glob -nocomplain -directory $ip_dir *.xci]
foreach ipf $ip_files {
  import_files -fileset sources_1 -norecurse $ipf
}

# Set top
set_property top oscilloscope_top [current_fileset]
update_compile_order -fileset sources_1

# Generate IP targets (may take a while the first time)
set ips [get_ips]
if {[llength $ips] > 0} {
  generate_target all $ips
}

puts "Project created at: $proj_dir"
puts "Next: open Vivado GUI with the generated .xpr in $proj_dir"

close_project
exit
