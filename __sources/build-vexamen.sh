#!/bin/bash
REGISTRY=${DOCKER_REGISTRY:-"quay.io/k8sexercices"}
TAG=${DOCKER_TAG:-"v1.0"}

pushd vexamen
docker build  --build-arg VERSION=${TAG} -t ${REGISTRY}/vexamen-server:${TAG}  .
popd

docker push ${REGISTRY}/vexamen-server:${TAG}