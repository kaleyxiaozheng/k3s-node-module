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
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init...'",
      "timeout 300s bash -c 'until [ -f /var/lib/cloud/instance/boot-finished ]; do sleep 5; done'",
      "curl -sfL https://get.k3s.io | sh -",
      "echo 'K3s installed'"
    ]
  }
}