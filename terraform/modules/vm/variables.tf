variable "name" {
  type = string
}

variable "node" {
  type = string
}

variable "template" {
  type = string
}

variable "cores" {
  type    = number
  default = 2
}

variable "memory" {
  type    = number
  default = 1024
}

variable "sockets" {
  type    = number
  default = 1
}

variable "disk_size" {
  type    = string
  default = "32G"
}

variable "cloud_init_filename" {
  type = string
}

variable "cloud_init_local_path" {
  type = string
}

variable "cloud_init_tpl_filename" {
  type = string
}

variable "pve_ip" {
  type = string
}

variable "private_key_path" {
  type = string
}

variable "ip_address" {
  type = string
}

variable "gateway_ip" {
  type = string
}

variable "nameserver" {
  type    = string
  default = "1.1.1.1"
}

variable "ssh_keys" {
  type = string
}

variable "pm_user" {
  type = string
}

variable "pm_password" {
  type = string
  sensitive = true
}

variable "pm_api_url" {
  type = string
}

variable "ciuser" {
  type = string
}

variable "cloud_init_vars" {
  description = "A map of cloud-init variables for the VM."
  type        = map(any)  # Allows for a flexible structure
}

