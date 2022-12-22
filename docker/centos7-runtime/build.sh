#!/bin/sh

export DOCKER_BUILDKIT=1
export BUILDKIT_PROGRESS=plain
docker build -t molpro-trampoline:centos7-runtime .
