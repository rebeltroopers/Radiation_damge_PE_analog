1. Run network_scrub_sidegroups.f90

Reads in a set of frames in either XYZ or LAMMPSTRJ
format that corresponds to the optimized end states
of NFRAME simulations. 

Need to set NFRAME value and file names in code.
Prints a LAMMPSTRJ file with only backbone atoms in it. 

Note that bond distances with hydrogen atoms 
in "bond_defs.txt" were set to zero, so we don't
consider any bonds with hydrogen in this analysis.

For decane, it might make more sense to include
the hydrogens (set bond cutoffs > 0). That way, this
scrubbing program will effectively scrub the hydrogens
and leave the whole backbones. Otherwise, you'll lose 
your terminal carbon atoms. 
	
_____________________________________

2. Run network_compute_connections.f90

This program computes network connections from 
LAMMPSTRJ file containing backbone atoms. It 
prints out NFRAME files to the directory "connections"
for subsequent processing. 

The files in "connections" contain the global graph
for each frame. 

_____________________________________

3. Run network_run_identify_components.sh 

This script runs a python script "network_identify_components.py"
in a loop over the NFRAME frames. This script reads in files in
"connections" and outputs files to "components". The files in 
directory "components" contain the same info as in "connections",
but with the individual connected components identified and indexed.

To continue, copy the files in "components" to the directory:

"step2_isomorphism_analysis/dir.backboneComponents"