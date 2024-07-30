#!/bin/bash
#Script to convert dumped xyz files to LAMMPS-style dump 
#and some hard-coded bits to push final configurations
#to directory dir.finalconfigs 

#Number of simulations  
NSIMS=30

#Make directory for keeping final configurations 
mkdir dir.finalconfig

#Compile programs 
gfortran -o convert_xyz2lammps convert_xyz2lammps.f90 

#Loop over simulations 
j=1
while [ $j -le $NSIMS ]; do

    #Enter lower level job directory
    cd workdir/sim.$j

    #Convert geo_end.xyz trajectory to a LAMMPS-style dump system.lammpstrj 
	#and a carbons-only trajectory onlycarbon.lammpstrj 
    ../../convert_xyz2lammps
	
	#Some hard-coded bits to get the final configurations and push them to 
	#dir.finalconfig with an index number matching the simulation number. 
	#Note that a LAMMPS-style dump frame has 9 header lines, so "tail -n201" 
	#captures the complete last frame with all 192 atoms from system.lammpstrj
    #and "tail -n73" does similarly for onlycarbon.lammpstrj. 
    tail -n201 system.lammpstrj > finalconfig.lammpstrj
    mv finalconfig.lammpstrj ../../dir.finalconfig/finalconfig.$j.lammpstrj
    tail -n73 onlycarbon.lammpstrj > carbons.lammpstrj
    mv carbons.lammpstrj ../../dir.finalconfig/carbons.$j.lammpstrj

    #Move back up
    cd ../../

    #Increment through sims
    let j=j+1

done


