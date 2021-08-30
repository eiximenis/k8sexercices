#!/bin/bash
REGISTRY=${DOCKER_REGISTRY:-"quay.io/k8sexercices"}
TAG=${DOCKER_TAG:-"v1.0"}

pushd fileserver
docker build -t ${REGISTRY}/fileserver:${TAG}  -f FileServer/Dockerfile .
popd

docker push ${REGISTRY}/fileserver:${TAG}