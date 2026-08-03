# output.tf

output "vm_id" {
  description = "The VM ID of the created node"
  value       = proxmox_virtual_environment_vm.node.vm_id
}

output "node_name" {
  description = "The name of the created node"
  value       = proxmox_virtual_environment_vm.node.name
}

output "ipv4_addresses" {
  description = "The IPv4 addresses of the created node"
  value       = proxmox_virtual_environment_vm.node.ipv4_addresses
}

output "cloud_init_config" {
  value = templatefile("${path.module}/templates/k3s-node-init.yaml.tpl", {
    hostname           = var.node_name,
    is_master          = var.node_type == "master",
    vm_password        = var.vm_password,
    ssh_public_key     = var.ssh_public_key_content,
    bootstrap_sh       = file("${path.module}/scripts/bootstrap.sh"),
    post_install_sh    = file("${path.module}/scripts/post-install.sh"),
    tailscale_auth_key = var.tailscale_auth_key,
    k3s_token          = var.k3s_token,
    master_ip          = var.master_ip != null ? var.master_ip : ""
  })
}

