#!/bin/bash
set -e

IS_MASTER="${is_master}"
TAILSCALE_KEY="${tailscale_auth_key}"
HOSTNAME_VAL="${hostname}"
MASTER_HOST_VAL="${master_host}"
K3S_TOKEN_VAL="${k3s_token}"
# --- 1. basic environment configuration (generic) ---
apt-get update && apt-get install -y qemu-guest-agent curl git
if [[ "$IS_MASTER" == "true" ]]; then
    apt-get install -y helm
fi
systemctl enable --now qemu-guest-agent

# --- 2. Tailscale configuration (generic) ---
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up --authkey="$TAILSCALE_KEY" --hostname="$HOSTNAME_VAL"

echo "Waiting for Tailscale interface to be ready..."
until tailscale ip -4 > /dev/null 2>&1; do sleep 2; done
TS_IP=$(tailscale ip -4)
echo "Tailscale is ready with IP: $TS_IP"

# --- 3. K3s installation logic (differentiated) ---
if [[ "$IS_MASTER" == "true" ]]; then
    echo "Installing K3s Master..."
    curl -sfL https://get.k3s.io | K3S_TOKEN="$K3S_TOKEN_VAL" INSTALL_K3S_EXEC="server --advertise-address=$TS_IP --tls-san=$TS_IP --tls-san=$MASTER_HOST_VAL" sh -
else
    echo "Waiting for Master API ($MASTER_HOST_VAL)..."
    until curl -skf https://${MASTER_HOST_VAL}:6443/healthz > /dev/null 2>&1; do sleep 5; done
    
    echo "Installing K3s Agent..."
    curl -sfL https://get.k3s.io | K3S_URL=https://${MASTER_HOST_VAL}:6443 K3S_TOKEN="$K3S_TOKEN_VAL" sh -
fi

# --- 4. Waiting for service to start (generic) ---
echo "Waiting for K3s service to be active..."
until systemctl is-active --quiet k3s || systemctl is-active --quiet k3s-agent; do sleep 5; done

# --- 5. Post-installation configuration (Master only) ---
if [[ "$IS_MASTER" == "true" && -f /usr/local/bin/post-install.sh ]]; then
    echo "Running post-install script on Master..."
    /usr/local/bin/post-install.sh
fi

echo "Node initialization completed."