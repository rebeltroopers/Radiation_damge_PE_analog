import numpy as np
import scipy
import sys
import math
import networkx as nx
import networkx.algorithms.isomorphism as iso

# Usage: python <this file> <graph1> <graph2>

fin1         	= sys.argv[1]
finstream1   	= open(fin1,'r')
newline1      	= finstream1.readline()
newline1        = finstream1.readline()
newline1        = finstream1.readline()
newline1        = finstream1.readline()
natom1 		    = int(newline1.split()[0])
newline1      	= finstream1.readline()

fin2         	= sys.argv[2]
finstream2   	= open(fin2,'r')
newline2      	= finstream2.readline()
newline2        = finstream2.readline()
newline2        = finstream2.readline()
newline2        = finstream2.readline()
natom2       	= int(newline2.split()[0])
newline2      	= finstream2.readline()

##### Get Graph 1 #####
graph1 		    = nx.Graph()
for i in xrange(natom1):
	newline1    = finstream1.readline()
	newnode     = int(newline1.split()[0])
	nodeatt     = (newline1.split()[1])
	graph1.add_node(newnode,el=nodeatt)
	
finstream1.seek(0,0)
newline1     	= finstream1.readline()
newline1     	= finstream1.readline()
newline1        = finstream1.readline()
newline1        = finstream1.readline()
newline1        = finstream1.readline()

for i in xrange(natom1):
	newline1    = finstream1.readline()
	atomi	    = int(newline1.split()[0])
	nbonds      = int(newline1.split()[2])
	for j in xrange(nbonds):
	 	atomj   = int(newline1.split()[int(j)+3])
		graph1.add_edge(atomi, atomj)

#for i in xrange(natom1):
#	nodequery=int(i)+1
#	print nodequery, graph1.node[nodequery]['el'], graph1.edges(nodequery)



##### Get Graph 2 #####
graph2 		    = nx.Graph()
for i in xrange(natom2):
	newline2    = finstream2.readline()
	newnode     = int(newline2.split()[0])
	nodeatt     = (newline2.split()[1])
	graph2.add_node(newnode,el=nodeatt)
	
finstream2.seek(0,0)
newline2     	= finstream2.readline()
newline2     	= finstream2.readline()
newline2        = finstream2.readline()
newline2        = finstream2.readline()
newline2        = finstream2.readline()

for i in xrange(natom2):
	newline2    = finstream2.readline()
	atomi	    = int(newline2.split()[0])
	nbonds      = int(newline2.split()[2])
	for j in xrange(nbonds):
	 	atomj = int(newline2.split()[int(j)+3])	
		graph2.add_edge(atomi, atomj)

#for i in xrange(natom1):
#	nodequery=int(i)+1
#	print nodequery, graph1.node[nodequery]['el'], graph1.edges(nodequery)



###### Check for isomorphism considering the node attributes (atom types) #####
nm = iso.categorical_node_match('el', 'X')
isoresult = nx.is_isomorphic(graph1, graph2, node_match=nm )

#print isoresult    #True/False
#print int(isoresult)    #1/0

##### Write out isomorphism check result #####
OFSTREAM = open("isocheck.txt", 'w')
OFSTREAM.write(`int(isoresult)` + "\n")
OFSTREAM.close()
