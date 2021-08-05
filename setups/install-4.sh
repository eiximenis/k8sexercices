ns=$(kubectl get ns logaiter --no-headers=true --ignore-not-found)
if [ -z "$ns" ]
then
    kubectl create ns logaiter
fi

for node in $(kubectl get nodes -o name);
do
    kubectl label $node logaiter/node-enabled-
done

kubectl create -f ex4