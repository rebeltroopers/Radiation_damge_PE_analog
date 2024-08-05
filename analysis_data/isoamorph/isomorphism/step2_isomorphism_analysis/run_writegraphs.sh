#!/bin/bash

##### Set nframe #####
nframe=100

##### Compile Programs #####
gfortran -o write_graphfile write_graphfile.f90 


##### Make Target Directory #####
mkdir	dir.backboneGraphs
rm		dir.backboneGraphs/* 


##### Make Book Keeping File #####
echo "#GraphIndex  frameIndex  componentIndex" > graph.record.txt 

##### Go Through Sims 
j=1
index=0
while [ $j -le $nframe ]; do

	echo $j

	##### Copy Input Files	
	cp dir.backboneComponents/frame.$j.txt frame.txt
	./write_graphfile

	##### Get Run Info #####
	ncomponent=$( head -n1 frame.txt | awk '{ print $3 }')

	##### Save Graphs
	i=1
	while [ $i -le $ncomponent ]; do

		#Save Graph
		mv graph.$i.txt dir.backboneGraphs/graph.$index.txt

		echo $index $j $i >> graph.record.txt 

		#Increment
		let i=i+1
		let index=index+1
		
	done

	#Increment
	let j=j+1

done

rm frame.txt
