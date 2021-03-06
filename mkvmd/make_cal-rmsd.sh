#!/bin/bash
# KevC @ 2019
# Bash script to calculate RMSD profile

PDB="$1"
TRJ="$2"
SELREF=("name CA")
SELRMSD=("name CA")
OUTPUT_NAME=("CA")
[ $# -eq 0 ] && { echo "mkvmd> Usage: $0 [PDB] [TRJ]"; echo "mkvmd> By default, the selection is '$SELRMSD'"; exit 1; }

if [ ! -f $PDB ]; then
    echo -e "$PDB \nStructure not found!"
    exit 0
fi

if [ ! -f $TRJ ]; then
    echo -e "$TRJ \nTrajectory not found!"
    exit 0
fi


echo "" > vm_cal-rmsd.tcl
cat >> vm_cal-rmsd.tcl << EOF

set mol [mol new $PDB waitfor all]
mol addfile $TRJ waitfor all
set num_frames [molinfo \$mol get numframes]
set sel_all [atomselect top all]

EOF

for ii in {0..0}
do
    
    cat >> vm_cal-rmsd.tcl << EOF
set sel_ref0 [atomselect top "${SELREF[$ii]}" frame 0]
set sel_ref [atomselect top "${SELREF[$ii]}"]
set sel_rmsd0 [atomselect top "${SELRMSD[$ii]}" frame 0]
set sel_rmsd [atomselect top "${SELRMSD[$ii]}"]
set outfile [open "rmsd_${OUTPUT_NAME[$ii]}.dat" "w"]
for {set i 0} {\$i<\$num_frames} {incr i} {
    \$sel_all frame \$i
    \$sel_ref frame \$i
    \$sel_rmsd frame \$i
    \$sel_all move [measure fit \$sel_ref \$sel_ref0]
    set rmsd [measure rmsd \$sel_rmsd \$sel_rmsd0]
    puts \$outfile "\$i \t \$rmsd"
}
close \$outfile


EOF

done

cat >> vm_cal-rmsd.tcl << EOF
quit
EOF

vmd -dispdev text -e vm_cal-rmsd.tcl 
