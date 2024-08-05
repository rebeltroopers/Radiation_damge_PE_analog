#!/bin/bash

##### Set nframe #####
nframe=100

mkdir   components
rm      components/*

##### Run Component Analysis
i=1
while [ $i -le $nframe ]; do

    echo "Frame $i"

    #Identify Connected Components in Graph
    python2 network_identify_components.py connections/frame.$i.txt 

    #Move Output
	mv components.txt components/frame.$i.txt

    #Increment
    let i=i+1

done


