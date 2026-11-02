#!/bin/bash
# SLURM batch script: run the youdo app under Darshan instrumentation on Mogon.
# Build it with make, then submit from this directory: sbatch job.slurm

#SBATCH --job-name=youdo-darshan
#SBATCH --account=nhr-hpckurs
#SBATCH --partition=smallcpu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --time=00:05:00
#SBATCH --output=youdo-darshan-%j.out
#SBATCH --error=youdo-darshan-%j.err

set -euo pipefail

HANDSON="$HOME/darshan-hands-on"
LIBDARSHAN="$HANDSON/darshan-install/lib/libdarshan.so"
LOGDIR="$HANDSON/logs"

# Same modules as for building Darshan and youdo
module purge
module load compiler/GCC devel/CMake mpi/OpenMPI lang/Python

OUTDIR="/lustre/project/nhr-hpckurs/day2/out/$USER/${SLURM_JOB_ID}"
mkdir -p "$OUTDIR" "$LOGDIR"

export DARSHAN_LOGFILE="$LOGDIR/youdo_${SLURM_JOB_ID}.darshan"
echo "Darshan file is saved at: $DARSHAN_LOGFILE"

# LD_PRELOAD only for the application ranks
mpirun -np "$SLURM_NTASKS" -x LD_PRELOAD="$LIBDARSHAN" -x DARSHAN_LOGFILE \
    "$SLURM_SUBMIT_DIR/youdo" "$OUTDIR/youdo.dat"

echo "Took: $SECONDS seconds."

