variable "ubuntu_template_id" {
  description = "The VM ID for the Ubuntu template"
  type        = number
  default     = 999
}
variable "node_name" { type = string }
variable "vm_id"     { type = number }
variable "memory"    { type = number }
variable "cpu_cores" { 
  type = number
  default = 2 
}
variable "static_ip" { 
  type = string
  default = null 
}
variable "gateway"   { 
  type = string
  default = null 
}
variable "ssh_public_key_content" {
  type = string
}
variable "ssh_private_key_path" {
  type = string
}

variable "vm_password" {
  type = string
  sensitive = true
}
variable "node_type" {
  type        = string
  description = "Node type: master or worker"
  default     = "worker" 
}
variable "k3s_token" {
  type        = string
  description = "The K3s cluster token"
}
variable "master_ip" {
  type        = string
  default     = "" # for worker node 
  description = "The IP address of the master node"
}

variable "tailscale_auth_key" {
  type        = string
  description = "The Tailscale auth key for node registration"
}