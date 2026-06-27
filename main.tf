# modules/k3s-node/main.tf

resource "proxmox_virtual_environment_file" "config" {
  content_type = "snippets"
  datastore_id = "local" # Make sure datastore is enabled for snippets
  node_name    = "pve"

  source_raw {
    data      = templatefile("${path.module}/templates/k3s-${var.node_type}-node-init.yaml.tpl", {
      hostname = var.node_name
    })
    file_name = "${var.node_name}-init.yaml"
  }
}
resource "proxmox_virtual_environment" "node" {
  name      = var.node_name
  node_name = "pve"
  vm_id     = var.vm_id

  clone { vm_id = var.ubuntu_template_id } # use Ubuntu template with cloud-init support (assumes template ID is 100)

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

    user_account {
      username = "ubuntu"
      password = var.vm_password # In production, use a more secure method to handle passwords
      keys     = [var.ssh_public_key_content] 
    }

    
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