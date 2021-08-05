#!/bin/bash
REGISTRY=${DOCKER_REGISTRY:-"quay.io/k8sexercices"}
TAG=${DOCKER_TAG:-"v1.0"}

pushd bm-images-api
docker build -t ${REGISTRY}/bmapi:${TAG}  .
popd

docker push ${REGISTRY}/bmapi:${TAG}