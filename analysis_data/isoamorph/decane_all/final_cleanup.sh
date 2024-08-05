#!/bin/bash

##### User Inputs
firstframe=0
lastframe=99
dumpfile='dump.lammpstrj'   #Lammps dump file

##### Identify RXNSTATES

cd  programs
    gfortran -o identify_rxnstates identify_rxnstates.f90
    cd ../

cp  outputs/descriptors.txt .
nglobalIndex=$( wc descriptors.txt | awk '{ print $1 }')
nglobalIndex=$(( $nglobalIndex - 1 ))
echo $nglobalIndex > control.txt

./programs/identify_rxnstates

mv rxnstates.txt        outputs/
mv unique.rxnstates.txt outputs/
rm descriptors.txt
rm control.txt


##### Extract representative atomic configurations

ngraphs=$( ls -lh outputs/lib.structures/graphs/ | wc | awk '{ print $1 }')
ngraphs=$(( $ngraphs - 1 ))

mkdir   outputs/lib.structures/configs
rm      outputs/lib.structures/configs/*

cd  programs
    gfortran -o extract_config extract_config.f90
    cd ../

cd  inputs

    echo $firstframe $lastframe  > control.txt
    echo $dumpfile              >> control.txt

    i=1
    while [ $i -le $ngraphs ]; do

        cp ../outputs/lib.structures/graphs/struct.$i.txt struct.txt
        ../programs/extract_config
        cp struct.lammpstrj ../outputs/lib.structures/configs/struct.$i.lammpstrj

        #Increment
        let i=i+1

    done

    rm control.txt
    rm struct.lammpstrj
    rm struct.txt

    cd ../

