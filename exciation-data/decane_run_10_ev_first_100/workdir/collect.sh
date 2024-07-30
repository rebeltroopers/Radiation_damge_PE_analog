#!/bin/bash

home=$(pwd)
for item in sim*
do
echo $item;
cd $item
echo $(pwd)
cp geo_end.xyz /p/lustre2/troup1/POLYETHYLENE-WORK/second_set/real_data/10eV_carbon_NEP_training_data/10eV_first_$item.xyz
cd $home
done

