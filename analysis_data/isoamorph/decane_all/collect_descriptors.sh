#!/bin/bash

##### User Inputs for Component Analysis Run
firstframe=0
lastframe=99

#Setup frame processing jobs
rm outputs/components.txt
njob=$(ls -lh dir.components.work | wc | awk '{ print $1 }')
njob=$(( $njob - 1 ))

job=1
while [ $job -le $njob ]; do

    cat dir.components.work/worker.$job/components.txt >> outputs/components.txt

    let job=job+1

done


#Compile and compute connections
cd  programs
    gfortran -o compute_descriptors compute_descriptors.f90
    cd ../

cd outputs

	mkdir   lib.structures
	mkdir   lib.structures/graphs
	rm      lib.structures/graphs/* 

    echo $firstframe $lastframe  > control.txt
    cp ../inputs/bond_defs.txt .
    ../programs/compute_descriptors
	mv struct.*.txt lib.structures/graphs/
    rm control.txt
    rm bond_defs.txt
    cd ../





