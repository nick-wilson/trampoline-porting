FROM centos:7

RUN yum install -y centos-release-scl-rh
RUN yum install -y devtoolset-11
RUN yum install -y python3

# MPItrampoline dependencies
RUN yum install -y wget
RUN cd /usr/local && wget -q https://github.com/Kitware/CMake/releases/download/v3.25.0/cmake-3.25.0-linux-x86_64.sh && bash cmake-3.25.0-linux-x86_64.sh --skip-license && rm -f cmake-3.25.0-linux-x86_64.sh
RUN yum install -y git

# GA autogen.sh dependencies
RUN yum install -y patch perl-Data-Dumper

# Molpro dependencies
RUN yum-config-manager --add-repo https://yum.repos.intel.com/mkl/setup/intel-mkl.repo
RUN rpm --import https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB
RUN yum install -y intel-mkl
RUN yum install -y libxml2-devel

RUN yum-config-manager --add-repo https://yum.repos.intel.com/mpi/setup/intel-mpi.repo
RUN yum install -y intel-mpi

ARG work=/work
RUN mkdir $work
ADD Molpro $work/Molpro

RUN cd $work && echo export PATH=/usr/local/bin:\$PATH > profile && echo source scl_source enable devtoolset-11 >> profile && echo source /opt/intel/mkl/bin/mklvars.sh intel64 >> profile && echo source /opt/intel/impi/2019.9.304/intel64/bin/mpivars.sh >> profile

RUN cd $work && source ./profile && git clone -b molpro/5.8.2 https://github.com/molpro/ga && cd ga && ./configure FC=mpif90 CXX=mpicxx CC=mpicc --with-mpi-pr --prefix=$work --with-blas=no --with-lapack=no --with-scalapack=no --disable-f77 && make -j 8 && make install

RUN cd $work && source ./profile && git clone https://github.com/eigenteam/eigen-git-mirror Eigen && cd Eigen && git checkout 3.3.7 && mkdir -p build && cd build && cmake -DCMAKE_INSTALL_PREFIX=$work .. && make install

ARG prefix=/opt/molpro
RUN cd $work && source ./profile && cd Molpro && ./configure FC=gfortran CXX=mpicxx --enable-mpp=ga FCFLAGS="-g" CFLAGS="-g" CXXFLAGS="-g" CPPFLAGS="-I${work}/include -I${work}/include/eigen3" --prefix=$prefix LDFLAGS="-L${work}/lib -Wl,-rpath,${MKLROOT}/lib/intel64" LAUNCHER='mpiexec -n %n %x' --bindir=${prefix}/bin && make -j 8 

RUN mkdir /root/.molpro
COPY token /root/.molpro/token

RUN cd $work && source ./profile && cd Molpro/testjobs && make quicktest MOLPRO_OPTIONS="-n 4"
