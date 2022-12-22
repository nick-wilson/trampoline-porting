#!/bin/bash

#SBATCH -A scw1323
#SBATCH -J MPItrampoline
#SBATCH -o slurm-%x.%j.o
#SBATCH -e slurm-%x.%j.e
#SBATCH --partition=dev
#SBATCH --time=1:00:00
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=40
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4g
#SBATCH --exclusive

export OMP_NUM_THREADS=${THREADS:-1}

module load compiler/gnu/11/3.0
module load mpi/intel/2020/4
export I_MPI_PMI_LIBRARY=/usr/lib64/libpmi.so

date
hostname
module list

mpitrampoline=$HOME/software/MPIwrapper/$SCWMPI/$SCWCOMPILER
export MPITRAMPOLINE_LIB=$mpitrampoline/lib64/libmpiwrapper.so

export SCRATCH=/scratch/$USER/tmp
if [ ! -d $SCRATCH ] ; then mkdir $SCRATCH ; fi

cd /scratch/c.sacnw3/install-Molpro-master-gnu-11.3-trampoline-mpi-pr/Molpro/testjobs
make quicktest
