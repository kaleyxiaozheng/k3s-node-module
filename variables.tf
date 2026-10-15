variable "ubuntu_template_id" {
  description = "The VM ID for the Ubuntu template"
  type        = number
  default     = 999
}
variable "node_name" { 
  description = "Name assigned to the Proxmox VM and its hostname"
  type = string 
}

variable "node_type" {
  type        = string
  description = "Node type: master or worker"
  default     = "worker" 
  validation {
    condition     = contains(["master", "worker"], var.node_type)
    error_message = "node_type must be either 'master' or 'worker'."
  }
}

variable "vm_id"{ 
  type = number 
  description = "Unique Proxmox VM identifier"
}

variable "memory" { 
  type = number 
  description = "Dedicated VM memory in megabytes"
}

variable "cpu_cores" { 
  type = number
  default = 2 
  description = "Number of virtual CPU cores"
  validation {
    condition     = var.cpu_cores >= 1
    error_message = "cpu_cores must be at least 1."
  }
}

variable "static_ip" { 
  type = string
  default = null
  nullable = true 
  description = "Static IPv4 address in CIDR notation, or null for DHCP"
}

variable "gateway"   { 
  type = string
  default = null 
  description = "IPv4 gateway for the node"
  nullable = true 
}

variable "ssh_public_key_content" {
  type = string
  description = "SSH public key installed for the Ubuntu user"
}

variable "vm_password" {
  description = "Password assigned to the Ubuntu user"
  type = string
  sensitive = true
}

variable "k3s_token" {
  type        = string
  sensitive   = true
  description = "Shared token used by nodes joining the K3s cluster"
}

variable "master_ip" {
  type        = string
  default     = null
  nullable    = true
  description = "IP address used to reach the K3s server"
}

variable "tailscale_auth_key" {
  type        = string
  description = "Ephemeral Tailscale authenticaltion key"
  sensitive   = true
}

variable "tailscale_auth_key" {
  type        = string
  description = "Ephemeral Tailscale authentication key"
  sensitive   = true
}

variable "snippet_datastore_id" {
  type        = string
  description = "Proxmox datastore ID for storing the cloud-init snippet"
  default     = "local"
}

variable "vm_datastore_id" { 
  type = string
  default = "local-lvm"
  description = "Proxmox datastore used for VM disks and initialization"
}

variable "network_bridge" { 
  type = string
  default = "vmbr0"
  description = "Proxmox network bridge for the VM"
}

variable "dns_servers" {
  type = list(string)
  description = "DNS servers configured through cloud-init"
  default = ["1.1.1.1", "8.8.8.8"]  
}