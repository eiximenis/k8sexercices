ns=$(kubectl get ns gag --no-headers=true --ignore-not-found)
if [ -z "$ns" ]
then
    kubectl create ns gag
fi

kubectl apply -f ex5