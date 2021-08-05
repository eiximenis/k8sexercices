#!/bin/bash
REGISTRY=${DOCKER_REGISTRY:-"quay.io/k8sexercices"}
TAG=${DOCKER_TAG:-"v1.0"}

pushd bm-seeder
docker build -t ${REGISTRY}/bmseeder:${TAG}   .
popd

docker push ${REGISTRY}/bmseeder:${TAG}