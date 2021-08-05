#!/bin/bash

ns=$(kubectl get ns bm-corp --no-headers=true --ignore-not-found)
if [ -z "$ns" ]; then
    kubectl create ns bm-corp 
fi
kubectl apply -f ex2