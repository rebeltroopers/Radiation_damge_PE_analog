#!/bin/csh
 
#MSUB -N pe30j1
#MSUB -l nodes=1
#MSUB -l ttc=4
#MSUB -l partition=borax
#MSUB -l walltime=00:120:00:00
#MSUB -A cbronze
#MSUB -q pbatch
#MSUB -V
 
module load intel/16.0.3
module load mvapich2/2.2
module load StdEnv
module load mkl
setenv OMP_NUM_THREADS 1
 
 
srun -N 1 -n 4 /usr/gapps/polymers/dftbplus-19.1/_build/prog/dftb+/dftb+ > output.txt
 
