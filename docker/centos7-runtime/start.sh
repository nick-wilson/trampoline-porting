#!/bin/bash

# start $ncontainer containers
ncontainer=${1:-2}
scratch=$(readlink -f ../centos7-build/scratch)
((i=0))
while [ $i -lt $ncontainer ] ; do
 docker run --rm -d -v $scratch:/scratch molpro-trampoline:centos7-runtime
 ((i=i+1))
done

# use "docker inspect network bridge" to identify IP addresses of containers
ip1=172.23.0.2
ip2=172.23.0.3

# extract user ssh keys
ssh -i id_rsa_docker user@$ip1
