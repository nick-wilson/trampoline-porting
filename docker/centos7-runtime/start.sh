#!/bin/bash

# start $ncontainer containers
ncontainer=${1:-2}
scratch=$(readlink -f ../centos7-build/scratch)
((i=0))
while [ $i -lt $ncontainer ] ; do
 docker run --rm -d -v $scratch:/scratch molpro-trampoline:centos7-runtime
 ((i=i+1))
done
