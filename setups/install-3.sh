#!/bin/bash

ns=$(kubectl get ns vex --no-headers=true --ignore-not-found)
if [ -z "$ns" ]; then
    kubectl create ns vex
fi
kubectl apply -f ex3