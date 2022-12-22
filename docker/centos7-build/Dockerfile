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

