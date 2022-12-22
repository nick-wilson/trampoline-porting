#!/bin/sh
if [ $# -ne 0 ] ; then
module load $*
else
module load compiler/gnu/11/3.0
module load mpi/intel/2020/4
fi

module list
type mpicc || exit 1
rm -rf MPIwrapper
git clone https://github.com/eschnett/MPIwrapper.git
cd MPIwrapper || exit $?
prefix=$HOME/software/MPIwrapper/$SCWMPI/$SCWCOMPILER
echo prefix=$prefix
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$prefix && \
cmake --build build && \
cmake --install build
