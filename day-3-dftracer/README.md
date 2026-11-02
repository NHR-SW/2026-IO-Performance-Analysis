# DFTracer Notes

## MOGON Hygiene for DFTracer

MOGON doesn't have any default module loaded when you logged in. Don't forget to load the necessary modules.

```bash
module load mpi/OpenMPI/5.0.3-GCC-13.3.0 
module load lang/Python/3.12.3-GCCcore-13.3.0
```

For this training, make sure to use these accounts and projects for your Slurm jobs: 

```
#SBATCH --account=nhr-hpckurs
#SBATCH --partition=ki-smallcpu
```

## General Python best practices

Due to the madness that can be induced by various Python libraries dependencies, always run your Python project inside a virtual environment.

```bash
# creating a virtual environment called dftracer-install
python -m venv [insert your environment name]
```

Once you have installed your own virtual environment, don't forget to activate it.

```bash
# activate the virtual environment
source [your environment directory]/bin/activate

```

Test if they `python` and `pip` are coming from the virtual environment you created. 

```bash
which pip
which python
```

Keep your `pip` up to date :smile: 

```
pip install --upgrade pip
```

## DFTracer Commons

Installing DFTracer: 

```bash
pip install --pre dftracer[dfanalyzer]
```
Necessary variables to run DFTracer: 
```bash
# DFTracer needs to be enabled explicitly in case there's an annotation inside that will be triggered during normal run
export DFTRACER_ENABLE=1

# set the mode for the DFTracer. PRELOAD collects everything inside the application
export DFTRACER_INIT=PRELOAD 

# set where the log of DFTracer will stored
export DFTRACER_LOG_FILE="$USER/dftracer-output“
```
Compacting DFTracer output
```bash
dftracer_split -n [application name] -c --verify
```
Running DFAnalyzer on the compacted output 
```bash
dfanalyzer \
  trace_path=[absolute path of the directory of the compacted traces] \
  analyzer/preset=posix \
  hydra.run.dir=[absolute path of the directory of the output]
```
Running the visualization server
```
dftracer_server -d [directory of the compacted traces]
```

## Miscellaneous

Sample scripts for this training can be found in: 

```
/lustre/project/nhr-hpckurs/DFTracer
```

