#!/bin/bash

##### User Inputs for Isomorphic Check Run
newlibrary=1                    #Rebuild Local Library of Structures Yes=1, No=0

workerfirstGlobalIndex=$(   head -n1 control.txt | tail -n1 | awk '{ print $1 }' )
workerlastGlobalIndex=$(    head -n1 control.txt | tail -n1 | awk '{ print $2 }' )
componentfile=$(            head -n2 control.txt | tail -n1 | awk '{ print $1 }' )
descriptorfile=$(           head -n3 control.txt | tail -n1 | awk '{ print $1 }' )

##### Start New Structure Library, if Requested
if [ $newlibrary -eq 1 ]
then
    #Make/Clean Library Directory
    mkdir lib.structures
    rm lib.structures/*
    rm lib.structures/*/*
    mkdir lib.structures/graphs

    #Make First Structure Definition
    let matchnum=workerfirstGlobalIndex+1
    natom=$(        grep -B 1 -m $matchnum '#ID' $componentfile | tail -n2 | head -n1 | awk '{ print $1 }')
    headlines=$(   grep -m $matchnum -n '#GLOBALINDEX' $componentfile | tail -n1 | awk '{ print $1 }' | awk '{split($0,a,":"); print a[1]}' )
    headlines=$(( $headlines + $natom + 4 ))
    taillines=$(( $natom + 5 ))
    head -n$headlines $componentfile | tail -n$taillines  > lib.structures/graphs/struct.0.txt

fi

##### Get Current Library Size
ngraphs=$( ls -lh lib.structures/graphs/struct.*  | wc | awk '{ print $1 }')

##### Run Analysis
i=$workerfirstGlobalIndex
while [ $i -le $workerlastGlobalIndex ]; do

    echo "GlobalIndex $i "

    #Export Current Graph Structure to File
    let matchnum=i+1
    natom=$(        grep -B 1 -m $matchnum '#ID' $componentfile | tail -n2 | head -n1 | awk '{ print $1 }')
    headlines=$(   grep -m $matchnum -n '#GLOBALINDEX' $componentfile | tail -n1 | awk '{ print $1 }' | awk '{split($0,a,":"); print a[1]}' )
    headlines=$(( $headlines + $natom + 4 ))
    taillines=$(( $natom + 5 ))
    head -n$headlines $componentfile | tail -n$taillines  > trialgraph.txt

    #Get descriptor type
    descriptorI=$(head -n2 trialgraph.txt | tail -n1 | awk '{ print $4 }')

    #Check Structural Isomorphism Against Current Library
    j=0
    isoflag=0
    while [ $j -lt $ngraphs ]; do

        #Get descriptor type
        descriptorJ=$(head -n2 lib.structures/graphs/struct.$j.txt | tail -n1 | awk '{ print $4 }')

        #Only bother with isomorphism test if descriptor types are equal
        if [ $descriptorI -eq $descriptorJ ]
        then

            #RUN PYTHON SCRIPT
            python check_isomorphism.py trialgraph.txt lib.structures/graphs/struct.$j.txt
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
        #Echo alert
        echo 'Found new structure, now there are: ' $ngraphs 
    fi

    #Append to structure log
    let descriptorLINE=i+2
    descriptorINFO=$(head -n$descriptorLINE $descriptorfile | tail -n1)
    if [ $i -le $workerfirstGlobalIndex ]
    then
        echo $descriptorINFO $structuretype > structures.txt
    else
        echo $descriptorINFO $structuretype >> structures.txt
    fi


    #Increment
    let i=i+1

done



