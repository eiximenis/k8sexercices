#!/bin/bash
REGISTRY=${DOCKER_REGISTRY:-"quay.io/k8sexercices"}
TAG=${DOCKER_TAG:-"v1.0"}

pushd primes
docker build -t ${REGISTRY}/primesapi:${TAG}  -f primes/Dockerfile .
popd

docker push ${REGISTRY}/primesapi:${TAG}