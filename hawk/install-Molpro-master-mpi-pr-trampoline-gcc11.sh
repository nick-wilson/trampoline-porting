#!/bin/sh

# Build Molpro for Hawk
# The installer needs personal permission to clone gitlab.com:molpro/Molpro
# Go to https://www.molpro.net/licensee/licensee.php?portal=licensee&choice=Account+information+and+ordering to request it (log in with user 'cardiff')

# configuration
molpro_version=master  # check https://www.molpro.net/download/ to see what's available
molpro_git_branch=master

module load use.own
module load git
module load cmake/3.25.0
module load compiler/gnu/11/3.0
module load mkl/2020/4
export SCWMPI=trampoline


_armci=mpi-pr

working_directory=/scratch/$USER/install-Molpro-$molpro_version-$SCWCOMPILER-$SCWMPI-$_armci # careful! if this directory already exists it will be completely destroyed first

#prefix=/apps/local/chemistry/molpro/$molpro_version/$SCWOS/$SCWCPU/$SCWCOMPILER/$SCWMPI # where to install to (system)
#prefix=/home/scwc0005/software/molpro/release # where to install to
#prefix=/scratch/$USER/software/molpro/release # where to install to
#prefix=$HOME/software/molpro/release # where to install to (user)
prefix=$HOME/software/molpro/$molpro_version/$SCWOS/$SCWCPU/$SCWCOMPILER/$SCWMPI/$_armci
eigen_version=3.3.7
#module load eigen/$eigen_version
ga_version=trampoline
make_processes=8
# end configuration - shouldn't need to change below here

thisdir="$PWD" # directory where scripts are located

if [ x$GITPATH != x ]; then export PATH=$GITPATH:$PATH; fi

rm -fr $working_directory && mkdir -p $working_directory && cd $working_directory || exit 1
mkdir -p ${prefix}/bin || exit 1

git clone git@github.com:eschnett/MPItrampoline.git
cd MPItrampoline
build=cmake-build
cmake -S . -B $build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$working_directory
cmake --build $build
cmake --install $build
export PATH="$working_directory/bin:$PATH"
cd $working_directory

git clone https://github.com/nick-wilson/ga || exit 1
cd ga || exit 1
git checkout $ga_version || exit 1
for patch in "$thisdir"/ga-*.patch ; do if [ -f "$patch" ] ; then echo apply patch $patch ; git apply $patch ; fi ; done
./autogen.sh
eval ./configure FC=mpif90 CXX=mpicxx CC=mpicc --with-$_armci --prefix=$working_directory --with-blas=no --with-lapack=no --with-scalapack=no --disable-f77
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

git clone git@github.com:molpro/Molpro || exit 1
cd Molpro
git checkout $molpro_git_branch || exit 1
for patch in "$thisdir"/molpro-*.patch ; do if [ -f "$patch" ] ; then echo apply patch $patch ; git apply $patch ; fi ; done
## export CXX_MPI_VENDOR=MPItrampoline # not required with latest master version
./configure FC=gfortran CXX=mpicxx --enable-mpp=ga CFLAGS="-g" FCFLAGS="-g" CXXFLAGS="-DMPIO_USES_MPI_REQUEST -g" CPPFLAGS="-I${working_directory}/include -I${working_directory}/include/eigen3" --prefix=$prefix LDFLAGS="-g -static-libstdc++ -static-libgcc -L${working_directory}/lib -Wl,-rpath,${MKLROOT}/lib/intel64 -Wl,-rpath,${GCC_ROOT}/lib64" LAUNCHER='srun %x' --bindir=${prefix}/bin
make -j$make_processes || exit 1
#make uninstall
make install
cd $working_directory

#cp -p "$thisdir"/qmolpro ${prefix}/bin
#majorminor=$(echo $molpro_version|sed -e 's/\([0-9]*\)\.\([0-9]*\).*$/\1.\2/')
#cd ${prefix}/bin; ln -sf ../molpro_${majorminor}/bin/molpro
#cd $working_directory
