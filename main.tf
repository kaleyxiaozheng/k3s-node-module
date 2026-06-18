# modules/k3s-node/main.tf

resource "proxmox_virtual_environment_vm" "node" {
  name      = var.node_name
  node_name = "pve"
  vm_id     = var.vm_id

  clone { vm_id = 100 } # use Ubuntu template with cloud-init support (assumes template ID is 100)

  cpu { 
    cores = var.cpu_cores
    type = "host" 
  }
  memory { dedicated = var.memory }
  agent { enabled = true }

  network_device { 
    bridge = "vmbr0"
    model = "virtio" 
  }

  initialization {
    datastore_id      = "local-lvm"
    user_data_file_id = proxmox_virtual_environment_file.config.id
    
    # dynamically check if it is using static IP
    dynamic "ip_config" {
      for_each = var.static_ip != null ? [1] : []
      content {
        ipv4 { 
          address = var.static_ip
          gateway = var.gateway 
        }
      }
    }
  }
}

resource "proxmox_virtual_environment_file" "config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve"
  source_raw {
    data      = var.user_data
    file_name = "${var.node_name}.yaml"
  }
}