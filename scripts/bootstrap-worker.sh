#!/bin/bash

# install Tailscale
# curl -fsSL https://tailscale.com/install.sh | sh
# tailscale up --authkey=${tailscale_auth_key} --hostname=${hostname} 

apt-get update && apt-get install -y qemu-guest-agent curl git
systemctl enable --now qemu-guest-agent

# waiting for Master API port
until nc -zv ${master_ip} 6443; do sleep 5; done

# join K3s cluster
curl -sfL https://get.k3s.io | K3S_URL=https://${master_ip}:6443 K3S_TOKEN=${k3s_token} sh -