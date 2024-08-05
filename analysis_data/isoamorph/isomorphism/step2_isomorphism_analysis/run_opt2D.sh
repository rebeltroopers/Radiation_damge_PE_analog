#!/bin/bash

##### Get Inputs #####
nstruct=$( ls -lh lib.structures/graphs | wc | awk '{ print $1 }')
let nstruct=nstruct-1
echo $nstruct

##### Lammps Executable #####
LMP_PATH='/home/natsc1/lammps_instal/lammps-29Oct20/src/lmp_mpi'

##### Compile Programs #####
gfortran -o write_datafile write_datafile.f90 

##### Clean Target Directory #####
rm lib.structures/configs/*

##### Go Through Graphs
j=0
while [ $j -lt $nstruct ]; do

	##### Copy Input Files
	cp lib.structures/graphs/struct.$j.txt struct.txt	
	./write_datafile

	#Optimize Backbone for Ploting
	$LMP_PATH -in in.pdms 

	#Keep final Config 
	natom=$( head -n3 data.pdms | tail -n1 | awk '{ print $1 }') 
	nline=$(($natom + 9))
	tail -n$nline dump.lammpstrj > lib.structures/configs/dump.$j.lammpstrj 

	#Increment
	let j=j+1

done

#rm data.*
#rm dump.lammpstrj 
#rm struct.txt
#rm log.lammps
rm write_datafile
