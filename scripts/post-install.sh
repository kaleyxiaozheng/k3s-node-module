#!/bin/bash

LOG_FILE="/var/log/post-install.log"
exec > >(tee -a ${LOG_FILE}) 2>&1

echo "Starting post-install configuration..."

TIMEOUT=900 
START_TIME=$(date +%s)

check_timeout() {
    local current_time
    current_time=$(date +%s)
    if ((current_time - START_TIME > TIMEOUT)) then
        echo "Error: Timeout reached during post-intall configuration." >&2
        exit 1
    fi
}

until [ -f /etc/rancher/k3s/k3s.yaml ]; do 
    echo "Waiting for K3s kubeconfig..."
    check_timeout
    sleep 5
done

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
export PATH="/usr/local/bin:$PATH"

until kubectl get nodes >/dev/null 2>&1; do
    echo "Waiting for Kubernetes API..."
    check_timeout
    sleep 5
done

until kubectl get nodes --no-headers 2>/dev/null | grep -q 'Ready'; do
    echo "Waiting for at least one Ready node..."
    check_timeout
    sleep 5
done

echo "=== Installing kube-prometheus-stack === "
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
helm repo update

# Sized for a small lab cluster (1x8GB server + 3 worker)
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --create-namespace \
    --wait \
    --timeout 20m \
    --set grafana.adminUser=admin \
    --set grafana.adminPassword=admin \
    --set grafana.resources.requests.memory=256Mi \
    --set grafana.resources.limits.memory=512Mi \
    --set prometheus.prometheusSpec.resources.requests.memory=512Mi \
    --set prometheus.prometheusSpec.resources.limits.memory=1Gi \
    --set alertmanager.alertmanagerSpec.resources.requests.memory=256Mi \
    --set alertmanager.alertmanagerSpec.resources.limits.memory=512Mi

kubectl -n monitoring get pods
echo "Post-install completed successfully."
echo "Grafana admin password: admin (change after first login)"
rm -f /usr/local/bin/post-install.sh