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