#!/bin/bash

key=$(< $HOME/.molpro/token)
scratch=$(readlink -f ../centos7-build/scratch)
docker run -u root --rm -i -v $scratch:/scratch molpro-trampoline:centos7-runtime /bin/bash << EOF

source scl_source enable devtoolset-11
source /opt/intel/mkl/bin/mklvars.sh intel64

#cd /scratch/install-Molpro/Molpro && make install

export PATH=/usr/local/bin:\$PATH
source /opt/intel/impi/2019.9.304/intel64/bin/mpivars.sh
cd /tmp
git clone https://github.com/eschnett/MPIwrapper.git
cd MPIwrapper
cmake -S . -B build -DMPIEXEC_EXECUTABLE=mpiexec -DCMAKE_BUILD_TYPE=Debug
cmake --build build
cmake --install build
export MPITRAMPOLINE_LIB=/usr/local/lib64/libmpiwrapper.so

cd /scratch
export MOLPRO_KEY="$key"
/scratch/install-Molpro/Molpro/bin/molpro he.inp

EOF
