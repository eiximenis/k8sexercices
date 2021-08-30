#!/bin/bash
clustertype=${CLUSTER_TYPE:-minikube}
exercices=""

while [ "$1" != "" ]; do
    case $1 in
        -c | --cluster)                 shift
                                        clustertype=$1
                                        ;;
        -e | --exs)                     shift
                                        exercices=$1
                                        ;;
       * )                              echo "Invalid param. Use -c or -e"
                                        echo "-c clustertype installs for the specified cluster (i. e. -c minikube)"
                                        echo "-e list-of-exercices installs only specified exercices (i. e. -e 1,2,3)"
                                        exit 1
    esac
    shift
done


echo "This will setup the cluster $clustertype for the exercices"

if [ -z "$exercices"]; then
    # Perform the cluster setup ONLY if -e is not used.
    pushd setups/clusters
    if [ -f "check-$clustertype.sh" ]; then
        echo "---- Checking $clustertype requeriments ----"
        source ./check-$clustertype.sh
        if [ $? -ne 0 ]; then
            popd
            exit 1
        fi
    else
        echo "---- $clustertype did NOT have any requeriment ----"
    fi
    echo "--- end ---"
    popd
fi
echo 
echo "---------- Creando namespaces -------------"
kubectl create ns ufo
kubectl create ns bm-corp
kubectl create ns logaiter
kubectl create ns gag
kubectl create ns vex
kubectl create ns logaiter

pushd setups
for setup in install-*.sh; do
    basename="${setup%.*}"                      # Get the file without the .sh extension
    if [[ ${basename%.*} == $basename ]]; then        # If the file had no other extension (i .e. is a single install-x.sh) process it
        index=$(echo $basename | sed '1 s/install-//')      # Get the number of exercice (i. e. 1 for install-1.sh)
        if echo ",$exercices," | grep -q ",$index," || [ -z "$exercices" ]; then
            echo "---- Processing exercice $index"
            if [ -f "$basename.$clustertype.sh" ]; then         # Check for existence of install.{clustertype}.sh to allow custom cluster setups
                echo "--- Running $basename.$clustertype.sh"
                source $basename.$clustertype.sh
            fi
            echo "--- Running $basename.sh"
            source $basename.sh
        fi
    fi
done
popd
