# modules/k3s-node/main.tf
resource "proxmox_virtual_environment_file" "config" {
  content_type = "snippets"
  datastore_id = "local" # 确保此 datastore 已启用 Snippets 功能
  node_name    = "pve"

  source_raw {
    data      = var.user_data
    file_name = "${var.node_name}-cloud-init.yaml"
  }
}
resource "proxmox_virtual_environment_vm" "node" {
  name      = var.node_name
  node_name = "pve"
  vm_id     = var.vm_id

  clone { vm_id = 100 } # use Ubuntu template with cloud-init support (assumes template ID is 100)

  cpu { 
    cores = var.cpu_cores
    type  = "host" 
  }
  memory { dedicated = var.memory }
  agent { enabled = true }

  network_device { 
    bridge = "vmbr0"
    model  = "virtio" 
  }

  initialization {
    datastore_id      = "local" # Must use same datastore as above file resource
    user_data_file_id = proxmox_virtual_environment_file.config.id
    
    # dynamically check if it is using static IP
    ip_config {
      ipv4 {
        address = var.static_ip != null ? var.static_ip : "dhcp"
        gateway = var.gateway
      }
    }
  }
lifecycle {
    ignore_changes = [
      initialization[0].ip_config,
      network_device
    ]
  }
}

resource "null_resource" "wait_for_node" {
  depends_on = [proxmox_virtual_environment_vm.node]
  
  provisioner "local-exec" {
    command = "echo 'Waiting for node ${var.node_name} to be ready...'; sleep 30"
  }
}