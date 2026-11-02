#!/bin/bash
# SLURM batch script: run HACC-IO under Darshan instrumentation on Mogon.
# Check all the TODOs, then submit from this directory: sbatch job.slurm

#SBATCH --job-name=hacc-io-darshan
#SBATCH --account=nhr-hpckurs
#SBATCH --partition=smallcpu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --time=00:05:00
#SBATCH --output=hacc-io-darshan-%j.out
#SBATCH --error=hacc-io-darshan-%j.err

set -euo pipefail

HANDSON="$HOME/darshan-hands-on"
LIBDARSHAN="$HANDSON/darshan-install/lib/libdarshan.so"
LOGDIR="$HANDSON/logs"

# Same modules as for building Darshan and HACC-IO
module purge
module load compiler/GCC devel/CMake mpi/OpenMPI lang/Python

# TODO: toggle between file-per-process and shared file
HACC_IO="$HANDSON/hacc-io/hacc_io.shared"
# HACC_IO="$HANDSON/hacc-io/hacc_io.fpp"

NUMPARTICLES=10000 # per rank, 38 bytes each

# TODO: change FS, half of the room starts with lustre, the other half with localscratch
OUTDIR="/lustre/project/nhr-hpckurs/day2/out/$USER/${SLURM_JOB_ID}" # Lustre FS
# OUTDIR="/localscratch/${SLURM_JOB_ID}/hacc" # node local SSD with ext4 FS
# OUTDIR="$HANDSON/out/${SLURM_JOB_ID}" # optional: home is a WAFL FS

mkdir -p "$OUTDIR" "$LOGDIR"

# Log name from binary and file system, e.g. hacc_io.shared_lustre_<jobid>.darshan
FSNAME="${OUTDIR#/}"
FSNAME="${FSNAME%%/*}"
export DARSHAN_LOGFILE="$LOGDIR/$(basename "$HACC_IO")_${FSNAME}_${SLURM_JOB_ID}.darshan"

echo "Start job ${SLURM_JOB_ID}"
echo "Run $HACC_IO with $NUMPARTICLES particles and write to $OUTDIR"
df -hT "$OUTDIR"
echo "Darshan file is saved at: $DARSHAN_LOGFILE"

# LD_PRELOAD only for the application ranks, not for this script or mpirun.
# Use mpirun (OpenMPI's own PMIx server), srun here launches singleton MPI ranks.
# HACC-IO appends -PartXXXXXXXX-of-XXXXXXXX.data to the given file name.
mpirun -np "$SLURM_NTASKS" -x LD_PRELOAD="$LIBDARSHAN" -x DARSHAN_LOGFILE \
    "$HACC_IO" "$NUMPARTICLES" "$OUTDIR/hacc"

echo "Took: $SECONDS seconds."

