# Hands-on: Darshan

Everything happens in `~/darshan-hands-on`, or similar:

```
~/darshan-hands-on/
  hacc/job.slurm        # job script for HACC-IO
  youdo/                # small MPI app with an I/O bottleneck
  darshan/              # git clone of Darshan
  darshan-install/      # your Darshan build
  hacc-io/              # git clone of HACC-IO
  logs/                 # Darshan logs of all jobs
```

# Workspace and modules
```
cp -r /lustre/project/nhr-hpckurs/day2/hands-on ~/darshan-hands-on
# or
git clone https://github.com/NHR-SW/2026-IO-Performance-Analysis
cp -r 2026-IO-Performance-Analysis/day-2-darshan/hands-on ~/darshan-hands-on
cd ~/darshan-hands-on

module purge
module load compiler/GCC devel/CMake mpi/OpenMPI lang/Python
which mpicc
# Check
```

# Build your own Darshan
```
cd ~/darshan-hands-on
git clone --branch 3.5.0 https://github.com/darshan-hpc/darshan.git
cd darshan
git submodule update --init
autoreconf -i
ls configure
# Check

# log path and job ID variable are required by configure
./configure --prefix=$HOME/darshan-hands-on/darshan-install \
    --with-log-path=$HOME/darshan-hands-on/logs \
    --with-jobid-env=SLURM_JOB_ID CC=mpicc
    --enable-apmpi-mod
make -j 8 install

ls ~/darshan-hands-on/darshan-install/lib/libdarshan.so
# Check
export PATH=$HOME/darshan-hands-on/darshan-install/bin:$PATH
darshan-parser --version
# Check

# DONT DO THAT NOW
# use it later by (never export LD_PRELOAD in your login shell):
LD_PRELOAD=$HOME/darshan-hands-on/darshan-install/lib/libdarshan.so ./your-app

# !important! where the log goes
export DARSHAN_LOGFILE=/some/path/to/file.darshan
# following will try to write into a year/month/day directory and will fail if not exist
export DARSHAN_LOGPATH=/some/path/

# for non MPI apps
export DARSHAN_ENABLE_NONMPI=1

# extended tracing, slower and more data
export DARSHAN_MOD_ENABLE=DXT_POSIX,DXT_MPIIO
# deprecated, still works: DXT_ENABLE_IO_TRACE=1
#-----------------
```

# Hacc-IO
```
cd ~/darshan-hands-on
git clone https://github.com/glennklockwood/hacc-io.git
cd hacc-io
make CXX=mpicxx clean fpp && cp hacc_io hacc_io.fpp     # file per process
make CXX=mpicxx clean all && cp hacc_io hacc_io.shared  # one shared file

# no Darshan linked in, we use LD_PRELOAD
ldd ./hacc_io.shared | grep -i darshan

cd ~/darshan-hands-on/hacc
vim job.slurm # TODO: binary (fpp/shared) and file system (lustre/localscratch)
sbatch job.slurm # submit job
squeue --me # check status
```
Four runs per person: fpp and shared, each on lustre and localscratch.
Half of the room starts with lustre, the other half with localscratch.

# [Analyze](https://darshan.readthedocs.io/en/stable/darshan-util/doc/darshan-util.html)
```
cd ~/darshan-hands-on/logs

## full record dump
darshan-parser <log> | less

## performance summary
darshan-parser --perf <log>
# Use the --file option to get totals based on file usage.
# Use the --total option to get all statistics as an aggregate total rather than broken down per file.

## compare two runs
darshan-diff <log1> <log2>
```

# youdo
```
cd ~/darshan-hands-on/youdo
make
sbatch job.slurm
# analyze the I/O and improve it:
vim youdo.c
# rerun and check the results via darshan
```
