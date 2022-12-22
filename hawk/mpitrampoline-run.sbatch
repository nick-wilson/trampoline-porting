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

input=he.inp

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

molpro_branch=master
molpro_version=2022.4
armci=mpi-pr
exe=$HOME/software/molpro/$molpro_branch/$SCWOS/$SCWCPU/$SCWCOMPILER/$SCWMPI/$armci/molpro_$molpro_version/bin/molpro
$exe $input
