resource "proxmox_virtual_environment_vm" "node" {
  name      = var.node_name
  node_name = "pve"
  vm_id     = var.vm_id

  clone { 
    vm_id        = var.ubuntu_template_id
    full         = true
  } 

  cpu { 
    cores = var.cpu_cores 
    type = "host" 
  }
  memory { dedicated = var.memory }
  agent { enabled = true }

  network_device { 
    bridge = "vmbr0"
    model  = "virtio" 
  }

  initialization {
    datastore_id      = "local-lvm"

    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id

    user_account {
      username = "ubuntu"
      password = var.vm_password
      keys     = [var.ssh_public_key_content] 
    }

    ip_config {
      ipv4 {
        address = var.static_ip != null ? var.static_ip : "dhcp"
        gateway = var.gateway
      }
      ipv6 {
        address = "dhcp"
      }
    }
    
    dns {
      servers = ["8.8.8.8"]
    }
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = var.static_ip != null ? split("/", var.static_ip)[0] : flatten(self.ipv4_addresses)[0]
  }
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve"

  source_raw {
    data = templatefile("${path.module}/scripts/bootstrap.sh", {
      tailscale_auth_key  = var.tailscale_auth_key,
      hostname            = var.node_name,
      is_master           = var.node_type == "master" ? "true" : "false",
      master_host         = var.master_ip,
      k3s_token           = var.k3s_token
    })
    file_name = "user-data-${var.node_name}.yaml"
  }
}