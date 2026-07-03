# modules/k3s-node/main.tf
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
    datastore_id      = "local-lvm" # Must use same datastore as above file resource

    user_account {
      username = "ubuntu"
      password = var.vm_password
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
 
 connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = var.static_ip != null ? split("/", var.static_ip)[0] : flatten(self.ipv4_addresses)[0]
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init...'",
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 2; done",
      "curl -sfL https://get.k3s.io | sh -", # 简化逻辑：直接在远程执行安装
      "echo 'K3s installed'"
    ]
  }
}