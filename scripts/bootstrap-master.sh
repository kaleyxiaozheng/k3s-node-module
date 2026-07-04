#!/bin/bash
set -e

# Start Agent
apt-get update && apt-get install -y qemu-guest-agent curl git helm
systemctl enable --now qemu-guest-agent

# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up --authkey=${tailscale_auth_key} --hostname=${hostname}

# wait for Tailscalse to be ready
echo "Waiting for Tailscale interface to be ready..."
until tailscale ip -4 > /dev/null 2>&1; do
    sleep 2
done
TS_IP=$(tailscale ip -4)
echo "Tailscale is ready with IP: $TS_IP"

# install K3s
# Passing parameter binding TS_IP to master node
# Passing K3S_URL and K3S_TOKEN for Agent
if [[ "${is_master}" == "true" ]]; then
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --advertise-address=$TS_IP --tls-san=$TS_IP" sh -
else
    # 这里记得把 K3S_URL 和 K3S_TOKEN 传进来
    curl -sfL https://get.k3s.io | K3S_URL=https://${master_tailscale_ip}:6443 K3S_TOKEN=${k3s_token} sh -
fi

echo "Waiting for K3s to be ready..."
until systemctl is-active --quiet k3s || systemctl is-active --quiet k3s-agent; do
    sleep 5
done
# ensure all are ready and then install Helm/Prometheus 
[ -f /usr/local/bin/post-install.sh ] && /usr/local/bin/post-install.sh