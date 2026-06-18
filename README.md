# K3s Node Terraform Module

This module automates the creation of K3s nodes (master or worker) using a base Ubuntu template, featuring automated network configuration and Cloud-Init injection.

## Module Functionality   
This module is designed to provision K3s nodes on Proxmox. 

## Key features include:  
- Automated Provisioning: Clones from a standard `Ubuntu template`.
- Network Configuration: Supports static IP assignment via Cloud-Init.
- Cloud-Init Integration: Seamlessly injects SSH keys and custom initialization scripts to prepare the environment for K3s installation.
</br>

## Input Variables

| Variable Name	| Type	| Description |
| :--- | :--- | :--- |
| hostname	| string	| The hostname of the VM (e.g., k3s-master-node) |
| ip_address | string	| Static IP address with CIDR (e.g., 192.168.50.101/24) |
| gateway	| string	| The default gateway for the node (e.g., 192.168.50.1) |
| ssh_pubkey	| string	| The public SSH key to be injected for authorized access |
| vm_id	| number	| The unique ID for the VM in the Proxmox cluster |

## Usage Example
Can easily instantiate this module in the root `main.tf` as shown below:

```bash
module "k3s_master" {
  source     = "./modules/k3s-node"
  hostname   = "k3s-master-node"
  vm_id      = 105
  ip_address = "192.168.50.101/24"
  gateway    = "192.168.50.1"
  ssh_pubkey = file("~/.ssh/id_ed25519.pub")
}
```