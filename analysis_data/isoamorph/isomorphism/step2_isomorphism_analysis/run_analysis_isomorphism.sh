#!/bin/bash

##### User Inputs for Isomorphic Check Run
newlibrary=1                    #Rebuild Local Library of Structures Yes=1, No=0

firstGlobalIndex=$(   head -n2 graph.record.txt | tail -n1 | awk '{ print $1 }' )
lastGlobalIndex=$(    tail -n1 graph.record.txt | awk '{ print $1 }' )

##### Start Structure Record
echo "#GraphIndex  StructureType" > structures.txt

##### Start New Structure Library, if Requested
if [ $newlibrary -eq 1 ]
then

    #Make/Clean Library Directory
    mkdir lib.structures
    rm lib.structures/*
    rm lib.structures/*/*
    mkdir lib.structures/graphs
    mkdir lib.structures/configs

    #Make First Structure Definition
	cp dir.backboneGraphs/graph.$firstGlobalIndex.txt  lib.structures/graphs/struct.0.txt
	#cp dir.backbone2D_opt/dump.$firstGlobalIndex.lammpstrj   lib.structures/configs/struct.0.lammpstrj

fi

##### Get Current Library Size
ngraphs=$( ls -lh lib.structures/graphs/struct.*  | wc | awk '{ print $1 }')

##### Run Analysis
i=$firstGlobalIndex
while [ $i -le $lastGlobalIndex ]; do

    echo "GlobalIndex $i "

    #Get Trial Graph
	cp dir.backboneGraphs/graph.$i.txt trialgraph.txt

    #Get descriptor type
    #descriptorI=$(head -n4 trialgraph.txt | tail -n1 | awk '{ print $4 }')
    descriptorI=$(head -n4 trialgraph.txt | tail -n1 | awk '{ print $2 }')

    #Check Structural Isomorphism Against Current Library
    j=0
    isoflag=0
    while [ $j -lt $ngraphs ]; do

        #Get descriptor type
        #descriptorJ=$(head -n4 lib.structures/graphs/struct.$j.txt | tail -n1 | awk '{ print $4 }')
        descriptorJ=$(head -n4 lib.structures/graphs/struct.$j.txt | tail -n1 | awk '{ print $2 }')

        #Only bother with isomorphism test if descriptor types are equal
        if [ $descriptorI -eq $descriptorJ ]
        then

            #RUN PYTHON SCRIPT
            python3 check_isomorphism.py trialgraph.txt lib.structures/graphs/struct.$j.txt
            isocheck=$(tail -n1 isocheck.txt | awk '{ print $1 }')
            #If the trial structure is isomorphic to a library structure, it isn't new
            if [ $isocheck -eq 1 ]
            then
                isoflag=1
                structuretype=$j
	            break #no need to check against other structuretypes
            fi

        fi

        #Increment
        let j=j+1

    done

    #If Structure is New, Update Library
    if [ $isoflag -eq 0 ]
    then
        let ngraphs=ngraphs+1
        structuretype=$(( $ngraphs - 1 ))
        #Save graph structure
        cp trialgraph.txt lib.structures/graphs/struct.$structuretype.txt
		#cp dir.backbone2D_opt/dump.$i.lammpstrj lib.structures/configs/struct.$structuretype.lammpstrj
        #Echo alert
        echo 'Found new structure, now there are: ' $ngraphs 
    fi

    #Append to structure log
	echo $i $structuretype >> structures.txt


    #Increment
    let i=i+1

done

rm trialgraph.txt 
rm isocheck.txt 
