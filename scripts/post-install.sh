#!/bin/bash

LOG_FILE="/var/log/post-install.log"
exec > >(tee -a ${LOG_FILE}) 2>&1

echo "Starting post-install configuration..."

TIMEOUT=600 
START_TIME=$(date +%s)

check_timeout() {
    CURRENT_TIME=$(date +%s)
    if [ $((CURRENT_TIME - START_TIME)) -gt $TIMEOUT ]; then
        echo "Error: Timeout reached during configuration."
        exit 1
    fi
}

# wait for K3s to start and generate kubeconfig file
until [ -f /etc/rancher/k3s/k3s.yaml ]; do 
  echo "Waiting for k3s.yaml..."
  check_timeout
  sleep 10
done
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# wait for API Server to be available
until kubectl get nodes >/dev/null 2>&1; do
    echo "Waiting for API server..."
    check_timeout
    sleep 10
done

set -e

# install Helm and Prometheus
echo "Installing Prometheus stack..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
# check if Prometheus is already installed, if yes then upgrade, if no then install
if helm status prometheus -n monitoring > /dev/null 2>&1; then
    echo "Prometheus already installed, upgrading..."
    helm upgrade prometheus prometheus-community/kube-prometheus-stack --namespace monitoring
else
    echo "Installing Prometheus for the first time..."
    helm install prometheus prometheus-community/kube-prometheus-stack --create-namespace --namespace monitoring
fi

# waiting for installation to complete and then remove the script itself (to keep the environment clean)
set +e
echo "Post-install completed successfully."
rm -f /usr/local/bin/post-install.sh