#!/bin/sh

# Build Molpro for MPItrampoline
# The installer needs personal permission to clone gitlab.com:molpro/Molpro
# Go to https://www.molpro.net/licensee/licensee.php?portal=licensee&choice=Account+information+and+ordering to request it (log in with user 'cardiff')

# configuration
molpro_version=master  # check https://www.molpro.net/download/ to see what's available
molpro_git_branch=master

source scl_source enable devtoolset-11
source /opt/intel/mkl/bin/mklvars.sh intel64
source /opt/intel/impi/2019.9.304/intel64/bin/mpivars.sh
export I_MPI_CC=gcc
export I_MPI_CXX=g++
export I_MPI_FC=gfortran



prefix=/opt/molpro
eigen_version=3.3.7

ga_version=trampoline
make_processes=8
# end configuration - shouldn't need to change below here

cd $(dirname "$0")
thisdir="$PWD" # directory where scripts are located

working_directory=$thisdir/install-Molpro-native # careful! if this directory already exists it will be completely destroyed first

if [ x$GITPATH != x ]; then export PATH=$GITPATH:$PATH; fi

rm -fr $working_directory && mkdir -p $working_directory && cd $working_directory || exit 1
mkdir -p ${prefix}/bin || exit 1

git clone https://github.com/nick-wilson/ga || exit 1
cd ga || exit 1
git checkout $ga_version || exit 1
for patch in "$thisdir"/ga-*.patch ; do if [ -f "$patch" ] ; then echo apply patch $patch ; git apply $patch ; fi ; done
./autogen.sh
eval ./configure FC=mpif90 CXX=mpicxx CC=mpicc --with-mpi-pr --prefix=$working_directory --with-blas=no --with-lapack=no --with-scalapack=no --disable-f77
make -j$make_processes && make install
cd $working_directory

git clone https://github.com/eigenteam/eigen-git-mirror Eigen || exit 1
cd Eigen
git checkout $eigen_version || exit 1
mkdir -p build || exit 1
cd build
cmake -DCMAKE_INSTALL_PREFIX=${working_directory} ..
make install
cd $working_directory

cp -a "$thisdir/Molpro" .
cd Molpro || exit $?
#for patch in "$thisdir"/molpro-mpitrampoline-*.patch ; do if [ -f "$patch" ] ; then echo apply patch $patch ; git apply $patch ; fi ; done
./configure FC=gfortran CXX=mpicxx --enable-mpp=ga FCFLAGS="-g" CFLAGS="-g" CXXFLAGS="-g" CPPFLAGS="-I${working_directory}/include -I${working_directory}/include/eigen3" --prefix=$prefix LDFLAGS="-static-libstdc++ -static-libgcc -L${working_directory}/lib -Wl,-rpath,${MKLROOT}/lib/intel64 -Wl,-rpath,${GCC_ROOT}/lib64" LAUNCHER='mpiexec -n %n %x' --bindir=${prefix}/bin
make -j$make_processes || exit 1
#make uninstall
#make install
cd $working_directory

#tar zcvf "$thisdir/molpro-install.tgz" $prefix
