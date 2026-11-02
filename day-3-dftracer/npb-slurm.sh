#!/bin/bash

#SBATCH --nodes=1
#SBATCH --tasks=9
#SBATCH --account=nhr-hpckurs
#SBATCH --partition=smallcpu
#SBATCH --time=00:15:00
#SBATCH --job-name=NPB-test
#SBATCH --output=NPB-%j.txt

# load necessary modules
module load mpi/OpenMPI/5.0.3-GCC-13.3.0
module load lang/Python/3.12.3-GCCcore-13.3.0

# check the list of modules
module list

# set the base directory 
BASE_DIR=/lustre/project/nhr-hpckurs/DFTracer

# add DFTracer variables
export DFTRACER_ENABLE=1
export DFTRACER_INIT=PRELOAD

# preload the DFTracer library
export LD_PRELOAD=$BASE_DIR/io-training/lib64/python3.12/site-packages/dftracer/lib64/libdftracer_preload.so

# running NAS parallel benchmark
mpiexec -n 9 $BASE_DIR/NPB3.4.4/NPB3.4-MPI/bin/bt.C.x.mpi_io_full

