#!/bin/bash

#SBATCH --tasks=16
#SBATCH --account=nhr-hpckurs
#SBATCH --partition=parallel
#SBATCH --time=00:30:00
#SBATCH --job-name=DLIO-test
#SBATCH --output=DLIO-%j.txt

# load necessary modules
module load mpi/OpenMPI/5.0.3-GCC-13.3.0
module load lang/Python/3.12.3-GCCcore-13.3.0

# check the list of modules
module list

# set the base directory 
BASE_DIR=/lustre/project/nhr-hpckurs/DFTracer

# activate the virtual environment
source $BASE_DIR/io-training/bin/activate

# preparing workload and data directory for DLIO
WORKLOAD=unet3d_v100
DATA_DIR=$BASE_DIR/dlio_data/$WORKLOAD
RUN_DIR=$BASE_DIR/dlio_results/$WORKLOAD
mkdir -p "$RUN_DIR"

# generating data for DLIO, tracing off
mpiexec -n 16 \
  -x DFTRACER_ENABLE=0 \
  dlio_benchmark workload=$WORKLOAD \
  ++workload.workflow.generate_data=True \
  ++workload.workflow.train=False \
  ++workload.dataset.data_folder=$DATA_DIR \
  ++hydra.run.dir=$RUN_DIR/generate

# run training, tracing on
mpiexec -n 16 \
  -x DFTRACER_ENABLE=1 \
  dlio_benchmark workload=$WORKLOAD \
  ++workload.workflow.generate_data=False \
  ++workload.workflow.train=True \
  ++workload.dataset.data_folder=$DATA_DIR \
  ++hydra.run.dir=$RUN_DIR/train

# compacting the traces
dftracer_split -d "$RUN_DIR/train" -o "$RUN_DIR/compacted" -n $WORKLOAD -c --verify