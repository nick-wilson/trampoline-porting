#!/bin/sh

if [ ! -d scratch/Molpro ] ; then (cd scratch && git clone git@github.com:molpro/Molpro.git) ; fi

export DOCKER_BUILDKIT=1
export BUILDKIT_PROGRESS=plain
docker build -t molpro-trampoline:centos7 .

docker run --rm -i -v $PWD/scratch:/scratch molpro-trampoline:centos7 /scratch/compile.sh
