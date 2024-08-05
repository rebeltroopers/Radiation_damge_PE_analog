1. Run run_writegraphs.sh

This script goes through the component files in 
"dir.backboneComponents" and writes individual
graph files for an isomorphism analysis. 

It also produces a file "graph.record.txt" that 
maintains a list that links each graph to a 
particular frame and component index. 
____________________________

2. Run run_analysis_isomorphism.sh

This script runs the whole isomorphism analysis by making 
calls to the python script "check_isomorphism.ps", which
does an isomorphism check between pairs of graphs. 

It produces a library of all isomorphically unique structures 
in the location "lib.structures/graphs". Note that the directory
"lib.structures/configs" is not used here. 

It also produces a file "structures.txt" which contains the
unique structure ID for every graph that we've processed. 
____________________________

3. Run run_opt2D.sh

This script executes the LAMMPS imput file "in.pdms", which 
uses a generic force field to make renderable quasi-2D 
configurations of the unique backbone structures. 

At a given iteration, it 

A. Calls write_datafile.f90 to make a LAMMPS data file for a
   particular graph

B. Executes LAMMPS to unfold the backbone configuration. 

A set of LAMMPSTRJ files will be placed in lib.structures/configs
for rendering with your favorite software (OVITO recommended). 

Make sure to set "LMP_PATH" to point to your LAMMPS executable.