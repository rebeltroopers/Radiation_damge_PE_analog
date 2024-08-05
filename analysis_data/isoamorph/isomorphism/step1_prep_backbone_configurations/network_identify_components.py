import numpy as np
import scipy
import sys
import math
import networkx as nx

# Usage: python <this file> <graph>

fin         	= sys.argv[1]
finstream   	= open(fin,'r')
newline      	= finstream.readline()
natom 		    = int(newline.split()[0])
frame 		    = int(newline.split()[1])
newline      	= finstream.readline()

##### Get Graph #####
graph 		    = nx.Graph()
for i in xrange(natom):
	newline     = finstream.readline()
	newnode     = int(newline.split()[0])
	nodeatt     = (newline.split()[1])
	graph.add_node(newnode,el=nodeatt)
	
finstream.seek(0,0)
newline     	= finstream.readline()
newline     	= finstream.readline()

for i in xrange(natom):
	newline     = finstream.readline()
	atomi	    = int(newline.split()[0])
	nbonds      = int(newline.split()[2])
	for j in xrange(nbonds):
	 	atomj   = int(newline.split()[int(j)+3])
		graph.add_edge(atomi, atomj)

#for i in xrange(natom):
#	nodequery=int(i)+1
#	print nodequery, graph.node[nodequery]['el'], graph.edges(nodequery)




##### Identify connected components (covalently bonded units) in graph #####

ncomponents     = nx.number_connected_components(graph)
component       = [[0 for x in range(natom)] for y in range(ncomponents)]
atPerComponent  = [0 for x in range(ncomponents)]
componentID  	= [-1 for x in range(natom)]

componentIndex = 0
for x in nx.connected_components(graph):
    elementIndex = 0
    for e in x:
        component[componentIndex][elementIndex] = int(e)
        elementIndex += 1
	
    atPerComponent[componentIndex] = elementIndex
    componentIndex += 1

for i in xrange(ncomponents):
    for j in xrange( atPerComponent[i] ):
    	index = component[i][j]
	componentID[index-1] = int(i)
        #print index, graph.node[index]['el'], i 
	
	
##### Print Components File #####
OFSTREAM = open("components.txt", 'w')
OFSTREAM.write(`natom` + ' ' + `frame` + ' ' + `ncomponents` + "\n")
OFSTREAM.write("#ID EL COMPONENT NBONDS BONDED_IDS \n")
	
for i in xrange(natom):
    index 	= int(i)  #starts at 0, whereas graph nodes/atom ids start at 1
    atomID	= index+1 #Starts at 1
    element	= str(graph.node[atomID]['el'])
    newCompID	= componentID[index] + 1
    degree 	= graph.degree(atomID)
    neighbors = [n for n in graph.neighbors(atomID)]
    
    OFSTREAM.write(`atomID` + ' ' + element + ' ' + `newCompID` + ' ' + `degree` + ' ')
    for j in xrange(degree):
    	OFSTREAM.write(`neighbors[j]` + ' ' )

    OFSTREAM.write(' ' + "\n")

#

#print neighbors[0]




x
#OFSTREAM = open("isocheck.txt", 'w')
#OFSTREAM.write(`int(isoresult)` + "\n")
#OFSTREAM.close()
