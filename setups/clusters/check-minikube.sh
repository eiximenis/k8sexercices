#!/bin/bash
mk=$(which minikube)
git=$(which git)

if [ -z "$mk" ]; then
    echo "---- minikube binary not found. Exiting"
    exit 1
fi

if [ -z "$git" ]; then
    echo "---- git binary not found. Exiting"
    exit 1
fi

echo "Enabling ingress & metrics-server on minikube..."
minikube addons enable ingress
minikube addons enable metrics-server

# path=$(mktemp -d -t mk-XXXXXXXXXX)