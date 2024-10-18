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

variable "gateway_ip" {
  type = string
}

variable "pve_ip" {
  type = string
}

variable "ip_address" {
  type = string
}

variable "cloud_init_vars" {
  description = "A map of cloud-init variables for different VMs."
  type        = map(map(any))
}
