resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve"
  overwrite    = true

  source_raw {
    file_name = "user-data-${var.node_name}.yaml"

    data = templatefile("${path.module}/templates/k3s-node-init.yaml.tpl", {
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
}


resource "proxmox_virtual_environment_vm" "node" {
  name      = var.node_name
  node_name = "pve"
  vm_id     = var.vm_id

  clone { 
    vm_id = var.ubuntu_template_id
    full  = true
  } 

  cpu { 
    cores = var.cpu_cores 
    type  = "host" 
  }

  memory { 
    dedicated = var.memory 
  }

  agent { 
    enabled = true 
  }

  network_device { 
    bridge = "var.network_bridge"
    model  = "virtio" 
  }

  initialization {
    datastore_id = var.vm_datastore_id
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id

    # Ensures SSH key + password even if custom user-date has issues
    user_accounts {
      username = "ubuntu"
      password = var.vm_password
      keys     = [trimspace(var.ssh_public_key_content)]
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
}
