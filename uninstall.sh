#!/bin/bash

echo "Eso va a establecer a eliminar todos los escenarios"
echo 
pushd setups
for setup in uninstall-*.sh; do
    echo "--- Ejecutando $setup"
    source $setup
done
echo "-------- Eliminando namespaces ------------"
kubectl delete ns ufo
kubectl delete ns bm-corp
kubectl delete ns logaiter
kubectl delete ns gag
kubectl delete ns vex
popd

