#!/bin/bash
#Script that submits jobs set up by initial_setup.sh

#Specify number of simulations to submit to queue 
NSIMS=100

#Loop to submit jobs 
j=1
while [ $j -le $NSIMS ]; do

    #Enter lower level job directory
    cd workdir/sim.$j

    #Submit job
    msub submit_borax.csh

    #Move back up
    cd ../../

    #Increment through sims
    let j=j+1

done


