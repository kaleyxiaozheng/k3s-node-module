variable "node_name" { type = string }
variable "vm_id"     { type = number }
variable "memory"    { type = number }
variable "user_data" { type = string }
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
variable "vm_password" {
  type = string
  default = "12345" # In production, use a more secure method to handle passwords
}