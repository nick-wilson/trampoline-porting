# MPItrampoline porting of Molpro

General build instructions
* Build MPItrampoline
* Compile application with MPItrampoline
* Build MPIwrapper with chosen MPI
* set ```MPITRAMPOLINE_LIB``` environment variable to location of wrapper library
* Run application

The ```docker``` directory has scripts used to build and run in CentOS 7 docker environment with GCC11.

## Building MPItrampoline
```
git clone git@github.com:eschnett/MPItrampoline.git
cd MPItrampoline
prefix=/opt/mpitrampoline
build=cmake-build
cmake -S . -B $build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$prefix
cmake --build $build
cmake --install $build
```
Add to PATH and compile application as normal:
```
export PATH="$prefix/bin:$PATH"
```
To change the compiler used by MPItrampoline wrappers
```
export MPITRAMPOLINE_CC=gcc
export MPITRAMPOLINE_CXX=g++
export MPITRAMPOLINE_FC=gfortran
```

## Building Global Arrays
Patches for GA can be found in ```patches-ga``` directory or with:
```
git clone -b trampoline https://github.com/nick-wilson/ga  # forked from develop branch
```

## Building Molpro
Patch to detect MPItrampoline at configure in ```patches-molpro``` directory (have been ported to ```master``` branch).

PPIDD compilation needs ```-DMPIO_USES_MPI_REQUEST``` added to ```CXXFLAGS```
```
./configure CXXFLAGS="-DMPIO_USES_MPI_REQUEST"
```

## Building MPIwrapper
```
# Add MPI to environment with "module load mpi" or "source /opt/intel/mpi/.../vars.sh"
git clone https://github.com/eschnett/MPIwrapper.git
cd MPIwrapper || exit $?
prefix=/opt/mpiwrapper
build=cmake-build
cmake -S . -B $build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$prefix && \
cmake --build $build && \
cmake --install $build
```
At runtime:
```
export MPITRAMPOLINE_LIB=$mpitrampoline/lib64/libmpiwrapper.so
```
