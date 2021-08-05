#!/bin/bash

ns=$(kubectl get ns ufo --no-headers=true --ignore-not-found)
if [ -z "$ns" ]; then
    kubectl create ns ufo
fi
kubectl apply -f ex1