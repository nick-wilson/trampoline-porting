#!/bin/sh

if [ ! -d Molpro ] ; then git clone git@github.com:molpro/Molpro.git ; fi

export DOCKER_BUILDKIT=1
export BUILDKIT_PROGRESS=plain
docker build -t molpro-centos7 .
