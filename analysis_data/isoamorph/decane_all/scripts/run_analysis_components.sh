#!/bin/bash

##### Get Inputs for Analysis Run
startframe=$(       head -n1 control.txt | tail -n1 | awk '{ print $1 }' )
endframe=$(         head -n1 control.txt | tail -n1 | awk '{ print $2 }' )
natom=$(            head -n2 control.txt | tail -n1 | awk '{ print $1 }' )
nqueryconnect=$(    head -n2 control.txt | tail -n1 | awk '{ print $2 }' )
connectfile=$(      head -n3 control.txt | tail -n1 | awk '{ print $1 }' )


##### Run Component Analysis
i=$startframe
while [ $i -le $endframe ]; do

    echo "Frame $i"

    #Export Current Graph Structure to File
    headlines=$(( $nqueryconnect*($i+1) ))
    head -n$headlines $connectfile | tail -n$nqueryconnect > connections.tmp.txt

    #Identify Connected Components in Graph
    python2 identify_components.py connections.tmp.txt

    #CAT Output
    if [ $i -eq $startframe ]
    then
        cp components.tmp.txt components.txt
    else
        cat components.tmp.txt >> components.txt
    fi

    #Increment
    let i=i+1

done



