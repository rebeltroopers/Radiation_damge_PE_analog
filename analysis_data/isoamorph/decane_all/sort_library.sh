#!/bin/bash

##### Get Number of Workers
nstructures=$( ls -lh outputs/lib.structures/graphs/ | wc | awk '{ print $1 }')
nstructures=$(( $nstructures - 1 ))

echo $nstructures

##### Setup sorted library directory

mkdir   outputs/lib.structures/sorted_configs
rm      outputs/lib.structures/sorted_configs/*

##### Run Fortran Sorting Program
cp programs/sort_products.f90 .
gfortran -o sort_products -fbounds-check sort_products.f90
echo $nstructures > tmp.txt 
./sort_products 
rm tmp.txt 

##### Sort Library

i=1
while [ $i -le $nstructures ]; do

    let nheadline=i+1

    newindex=$( head -n$nheadline sort_output.txt | tail -n1 | awk '{ print $1 }')
    oldindex=$( head -n$nheadline sort_output.txt | tail -n1 | awk '{ print $2 }')

    echo $newindex $oldindex
    cp outputs/lib.structures/configs/struct.$oldindex.lammpstrj outputs/lib.structures/sorted_configs/struct.$newindex.lammpstrj

    #Increment
    let i=i+1

done

rm sort_products
rm sort_products.f90