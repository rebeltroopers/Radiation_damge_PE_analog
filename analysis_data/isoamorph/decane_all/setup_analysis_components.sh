#!/bin/bash

##### User Inputs for Component Analysis Run
jobid='work'
firstframe=0
lastframe=99
frameperjob=401
dumpfile='dump.lammpstrj'   #Lammps dump file

##### Setup Analysis Runs
nframe=$(perl -w -e "use POSIX; print floor(($lastframe-$firstframe)), qq{\n}")
njob=$(  perl -w -e "use POSIX; print floor(($nframe)/$frameperjob)+1, qq{\n}")

echo $nframe $njob

#Get Main Directory Path
pwddir=`pwd`
connect_path="$pwddir/outputs/connections.txt"

#Make working directory
mkdir   dir.components.work
rm -r   dir.components.work/*

#Compile and compute connections
cd  programs
    gfortran -o compute_connections compute_connections.f90
    cd ../

cd  inputs
    echo $firstframe $lastframe  > control.txt
    echo $dumpfile              >> control.txt
    ../programs/compute_connections
    natom=$( head -n4 $dumpfile | tail -n1 | awk '{ print $1 }' ) #Number of atoms in system
    nqueryconnect=$(( $natom+2 ))
    nquerydump=$(( $natom+9 ))
    mv connections.txt ../outputs
    rm control.txt
    cd ../

#Setup frame processing jobs
cd dir.components.work
frame=$firstframe
job=1
while [ $job -le $njob ]; do

    mkdir   worker.$job
    cd      worker.$job

    #Copy scripts
    cp ../../scripts/*components* .

    #Make control file
    workerFirstFrame=$(( $frameperjob*($job-1) + $firstframe ))
    workerLastFrame=$(( $frameperjob*$job + $firstframe - 1))
    if [ $workerLastFrame -gt $lastframe ]
    then
        workerLastFrame=$lastframe
    fi
    echo $workerFirstFrame $workerLastFrame  > control.txt
    echo $natom $nqueryconnect              >> control.txt
    echo $connect_path                      >> control.txt


    cd ../

    let job=job+1

done

cd ../

#write submit script




