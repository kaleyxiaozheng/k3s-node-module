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
