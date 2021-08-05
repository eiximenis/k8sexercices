kubectl delete -f ex4

for node in $(kubectl get nodes -o name);
do
    kubectl label $node logaiter/node-enabled-
done
