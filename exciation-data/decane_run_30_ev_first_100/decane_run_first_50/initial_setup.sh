#!/bin/bash
#Script to setup an ensemble of velocity excitation simulations 

#Specify number of simulations in ensemble
NSIMS=50

#Specify a "global" job ID and computing bank 
jobid='pe30j'
bank='cbronze'

#Specify inputs to make_velocities.f90 that
#determine the initial velocity condition
Ttherm='300.0'			#Initial thermal temperature of the system in Kelvin
Texcite='232090.362'		#Excitation energy for excited atom in Kelvin (KE = 3*kB*T/2)
excitedatom=266			#Index for chosen atom to be excited 			
#below is nate modified to create independent runs
base_value="frame_" #the sequence that they are organized inside of the directory
lammpstrj_path='/usr/workspace/troup1/second_set/initial_frames/OPLS_initial_runs/first_set/' #the path to the file and needs a "/" at the end
start_frame=1
python_path='/usr/workspace/troup1/second_set/python_scripts/'
python3 "$python_path/carbon_list_maker.py" "$lammpstrj_path$base_value$start_frame.lammpstrj"
read -a carbon_array < carbon_list_temp.txt #hard coded in python to make this file name and is reading i the array
echo ${carbon_array[1]}

#Specity path to DFTB+ executable 
DFTB_PATH='/usr/gapps/polymers/dftbplus-19.1/_build/prog/dftb+/dftb+'


#Prepare programs and working directories for new run
#WARNING: This will remove any prior jobs run in workdir! 
pwddir=`pwd`

mkdir workdir
rm -r workdir/*

gfortran -o make_velocities make_velocities.f90

#Copy thermalized configuration that will be used to prepare gen files
#Program make_velocities.f90 expects a specific LAMMPS dump format.
#Name of LAMMPS dump file must match here and in program make_velocities.f90 
cp template_files/dump.final.pe.lammpstrj .

#Loop to setup working directories 
j=1
while [ $j -le $NSIMS ]; do

        #Make lower level job directory
        mkdir workdir/sim.$j
	echo number of itteration $j
	#copy over the new configuratons due to my modification so they are more independent
#	cp "$lammpstrj_path$base_value$j.lammpstrj" dump.final.pe.lammpstrj
        cp "$lammpstrj_path$base_value$start_frame.lammpstrj" dump.final.pe.lammpstrj
 #       length=${carbon_array[@]}
#        echo $length
        picked_atom=$(shuf -i 0-$((${#carbon_array[@]}-1)) -n 1)
	excitedatom=${carbon_array[$picked_atom]}
	echo the picked atom $picked_atom
	echo the atom that got excited $excitedatom
	#end of nate modified
        #Prep GEN and DFTB input files
        echo $Ttherm $Texcite > control.txt
        echo $excitedatom   >> control.txt
        echo $RANDOM        >> control.txt
        ./make_velocities
        cp template_files/dftb_in_part1.hsd     dftb_in.hsd
        cat velocities.txt                   >> dftb_in.hsd
        cat template_files/dftb_in_part2.hsd >> dftb_in.hsd
        mv dftb_in.hsd                          workdir/sim.$j
        mv system.gen                           workdir/sim.$j

        #Make submission script
        echo '#!/bin/csh'                                    > submit_borax.csh
        echo ' '                                            >> submit_borax.csh
        echo '#MSUB -N '$jobid$j                            >> submit_borax.csh
        echo '#MSUB -l nodes=1'                             >> submit_borax.csh
        echo '#MSUB -l ttc=4'                               >> submit_borax.csh
        echo '#MSUB -l partition=borax'                     >> submit_borax.csh
        echo '#MSUB -l walltime=00:120:00:00'               >> submit_borax.csh
        echo '#MSUB -A '$bank                               >> submit_borax.csh
        echo '#MSUB -q pbatch'                              >> submit_borax.csh
        echo '#MSUB -V'                                     >> submit_borax.csh
        echo ' '                                            >> submit_borax.csh
        echo 'module load intel/16.0.3'                     >> submit_borax.csh
        echo 'module load mvapich2/2.2'                     >> submit_borax.csh
        echo 'module load StdEnv'                           >> submit_borax.csh
        echo 'module load mkl'                              >> submit_borax.csh
	echo 'setenv OMP_NUM_THREADS 1'                  >> submit_borax.csh
        echo ' '                                            >> submit_borax.csh
        echo 'cd '$pwddir'/workdir/sim.'$j                  >> submit_borax.csh
        echo ' '                                            >> submit_borax.csh
        echo 'srun -N 1 -n 4 '$DFTB_PATH' > output.txt'     >> submit_borax.csh
        echo ' '                                            >> submit_borax.csh

        #Move submission script
        mv submit_borax.csh workdir/sim.$j/submit_borax.csh

        #Increment through walkers
        let j=j+1


done

#Final cleanup
rm dump.final.pe.lammpstrj
rm control.txt
rm velocities.txt

