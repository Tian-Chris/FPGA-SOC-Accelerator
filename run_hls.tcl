open_project fmult
set_top fmult
cd fmult
add_files fmult.cpp
open_solution "solution1"
set_part xc7a35tcpg236-1
create_clock -period 10 -name default
csynth_design
export_design -format ip_catalog
close_project
cd ..

open_project fadd
set_top fadd
cd fadd
add_files fadd.cpp
open_solution "solution1"
set_part xc7a35tcpg236-1
create_clock -period 10 -name default
csynth_design
export_design -format ip_catalog
close_project
cd ..
