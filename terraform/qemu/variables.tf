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

variable "keepalived_auth_type" {
  type = string
}

variable "keepalived_pass" {
  type = string
}
