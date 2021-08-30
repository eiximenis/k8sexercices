ns=$(kubectl get ns logaiter --no-headers=true --ignore-not-found)
if [ -z "$ns" ]
then
    kubectl create ns logaiter
fi

kubectl apply -f ex6