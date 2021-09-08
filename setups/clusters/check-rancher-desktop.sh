nginxVersion=${NGINX_INGRESS_VERSION:-"controller-v1.0.0"}
#!/bin/bash
currentctx=$(kubectl config current-context)
git=$(which git)

if [[ "$currentctx" == "rancher-desktop" ]]; then
    echo "---- Current context is rancher-desktop. Ok"
else
    $rancherctx = $(kubectl config get-contexts | grep rancher-desktop)
    if [[ -z "$rancherctx" ]]; then
        echo "---- Context rancher-desktop not found. Exiting..."
        exit 1
    fi
    echo "---- Switching to rancher-desktop context"
    kubectl config use-context rancher-desktop
fi


nginxNs=$(kubectl get ns | grep ingress-nginx | awk '{print $1}')

if [[ -z "$nginxNs" ]]; then
    echo "---- Namespace ingress-nginx do not exists. Need to install ingress-nginx..."
    echo "---- Installing ingress-nginx controller (version $nginxVersion)"
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/$nginxVersion/deploy/static/provider/baremetal/deploy.yaml
    echo "---- Waiting for ingress-nginx to start..."

    nginxpodstatus=$(kubectl get pods -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx  -l app.kubernetes.io/component=controller --ignore-not-found --no-headers | awk '{print $3}')
    while [[ "$nginxpodstatus" != "Running" ]]; do
        echo "Current nginx pod status $nginxpodstatus"
        sleep 10
        nginxpodstatus=$(kubectl get pods -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx  -l app.kubernetes.io/component=controller --ignore-not-found --no-headers | awk '{print $3}')
    done
    echo "nginx-ingress installed. Good!"
else 
    echo "---- Namespace ingress-nginx exists. Ok"
fi

# path=$(mktemp -d -t mk-XXXXXXXXXX)