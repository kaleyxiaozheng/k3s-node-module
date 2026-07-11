#!/bin/bash
set -e

# --- 1. basic environment configuration (generic) ---
apt-get update && apt-get install -y qemu-guest-agent curl git ${is_master == "true" ? "helm" : ""}
systemctl enable --now qemu-guest-agent

# --- 2. Tailscale configuration (generic) ---
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up --authkey=${tailscale_auth_key} --hostname=${hostname}

echo "Waiting for Tailscale interface to be ready..."
until tailscale ip -4 > /dev/null 2>&1; do sleep 2; done
TS_IP=$$(tailscale ip -4)
echo "Tailscale is ready with IP: $$TS_IP"

# --- 3. K3s installation logic (differentiated) ---
if [[ "${is_master}" == "true" ]]; then
    echo "Installing K3s Master..."
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --advertise-address=$$TS_IP --tls-san=$$TS_IP" sh -
else
    echo "Waiting for Master API..."
    until curl -skf https://${master_host}:6443/healthz > /dev/null 2>&1; do sleep 5; done
    
    echo "Installing K3s Agent..."
    curl -sfL https://get.k3s.io | K3S_URL=https://${master_host}:6443 K3S_TOKEN=${k3s_token} sh -
fi

# --- 4. Waiting for service to start (generic) ---
echo "Waiting for K3s service to be active..."
until systemctl is-active --quiet k3s || systemctl is-active --quiet k3s-agent; do sleep 5; done

# --- 5. Post-installation configuration (Master only) ---
if [[ "${is_master}" == "true" && -f /usr/local/bin/post-install.sh ]]; then
    echo "Running post-install script on Master..."
    /usr/local/bin/post-install.sh
fi

echo "Node initialization completed."