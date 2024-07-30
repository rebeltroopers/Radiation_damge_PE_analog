This directory contains everything to setup, run, and partially analyze 
an ensemble of DFTB+ simulations in which an hydrogen atom is excited in 
a pre-thermalized polyethylene (PE) crystal. 

___________________________________________________________________________________ 

Directories...
___________________________________________________________________________________ 

template_files 	
Contains necessary DFTB+ input file components and the pre-thermalized PE 
configuration dump.final.pe.lammpstrj in a specific LAMMPS-style dump. 

pbc-0-3
Slater-Koster files referenced by DFTB+ input files 

workdir
A directory containing more directories, one for each simulation. If not 
already present, it will be created (or wiped-clean) by initial_setup.sh. 

dir.finalconfig
Contains final configurations extracted by script get_lastframe.sh If not
already present, it will be created by get_lastframe.sh. 


___________________________________________________________________________________ 

Scripts and Programs...
___________________________________________________________________________________ 

initial_setup.sh 
BASH script that sets up an ensemble of NSIM simulations. Contains control
parameters to be set by USER and will wipe clean any previous jobs in workdir. 

submit_jobs.sh 
BASH script that enters the NSIM workdir/sim.* directories and submits the 
SLURM submit scripts make by initial_setup.sh to the queue on BORAX. 

get_lastframe.sh
BASH script that converts DFTB+ trajectories in geo_end.xyz to LAMMPS-style dump
and has hard-wired bits to extract the final configurations and push them to 
directory dir.finalconfig 

make_velocities.f90 
FORTRAN program that takes parameters dumped to temporary file control.txt and 
produces the initial velocity condition for each simulation. 

convert_xyz2lammps.f99
FORTRAN program that converts geo_end.xyz to two LAMMPS-style dumps. One contains 
all atoms and the other contains only carbon atoms. 

___________________________________________________________________________________ 

General Workflow
___________________________________________________________________________________ 

1. Run initial_setup.sh
2. Run submit_jobs.sh 
3. Wait for all NSIM jobs to run on BORAX
4. Run get_lastframe.sh and do your own analyses 

___________________________________________________________________________________ 

Notes on USER-Specified Things 
___________________________________________________________________________________ 

DFTB+ input files are contructed by initial_setup.sh by concatonating three files 
together in the following order.

1. dftb_in_part1.hsd
2. velocities.txt (temporary file produced by make_velocities.f90)
3. dftb_in_part2.hsd 

dftb_in_part1.hsd contains parts with the Driver, so you can modify it to increase 
the simulation time and other parameters. Currently it is set to run NVE dynamics 
with Extended-Lagrangian Born-Oppenheimer equations of motion. The only critical
part is that the last line must be "Velocities [m/s] {" for the concatonation to 
work as indended. 

dftb_in_part2.hsd contains parts with the Hamiltonian and other options. Note that 
some of the SCC-related parameters are overruled by Xlbomd in the Driver section. 

Variables specifying the excitation strength and which atom gets excited are in
the script initial_setup.sh. 

___________________________________________________________________________________ 

Some Miscellanous Things 
___________________________________________________________________________________ 

Using OVITO to visualize the LAMMPS-style dumps is highly recommended. An example
OVITO program state file is included that will render the final configurations in
directory dir.finalcongif. You can also use it to read in the individual simulation
trajectories workdir/sim.*/system.lammpstrj, but you will need to tell OVITO to 
expect a timeseries (a clickable box under the INPUTS section). Ovito will be better 
than VMD for this work as it can draw bonds across the periodic boundary and has a 
host of other analysis and trajectory manipulation tools. 

The original simulations in workdir were run in a slightly different directory 
structure where pbc-0-3 was placed somewhat higher. Thus, there will be some small
differences in the gen files between a freshly initialized set of simulations and 
the old ones that are currently there for purposes of demonstration. 










