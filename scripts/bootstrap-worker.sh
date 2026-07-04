#!/bin/bash
set -e 

# 1. install qemu-guest-agent, curl, git
apt-get update && apt-get install -y qemu-guest-agent curl git
systemctl enable --now qemu-guest-agent

# 2. Tailscale configuration
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up --authkey=${tailscale_auth_key} --hostname=${hostname}

# 3. waiting for Tailscale network to be ready (must ensure the node is in the Tailscale internal network)
echo "Waiting for Tailscale interface to be ready..."
until tailscale ip -4 > /dev/null 2>&1; do
    sleep 2
done
echo "Tailscale is ready."

# 4. waiting for Master node API service to be ready
# Note: Here we use ${master_tailscale_ip} because the node is already in the same Tailscale network
MASTER_HOST="k3s-master-node"
echo "Waiting for Master node at ${MASTER_HOST}:6443..."
until curl -skf https://${MASTER_HOST}:6443/healthz > /dev/null 2>&1; do
    echo "Master API not ready yet, retrying..."
    sleep 5
done

# 5. join K3s cluster
echo "Joining K3s cluster..."
curl -sfL https://get.k3s.io | K3S_URL=https://${MASTER_HOST}:6443 K3S_TOKEN=${k3s_token} sh -

# 6. waiting for Agent service to start
echo "Waiting for K3s agent to be ready..."
until systemctl is-active --quiet k3s-agent; do
    sleep 5
done

echo "Worker node joined successfully."