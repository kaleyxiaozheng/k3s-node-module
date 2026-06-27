# output.tf

output "vm_id" {
  description = "The VM ID of the created node"
  value       = proxmox_virtual_environment.node.vm_id
}

output "node_name" {
  description = "The name of the created node"
  value       = proxmox_virtual_environment.node.name
}

output "ipv4_addresses" {
  description = "The IPv4 addresses of the created node"
  value       = proxmox_virtual_environment.node.ipv4_addresses
}