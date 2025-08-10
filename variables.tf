variable "location" {
  type    = string
  default = "polandcentral"
}

variable "resource_group_name" {
  type    = string
  default = "sdx-rg"
}

variable "vnet_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "admin_username" {
  type    = string
  default = "sdxuser"
}

variable "ssh_public_key" {
  type        = string
  description = "OpenSSH public key"
}

variable "project_prefix" {
  description = "Tüm kaynak adlarının başına gelen kısaltma"
  type        = string
  default     = "esra"
}

variable "private_key_path" {
  description = "Path to the private SSH key used to connect to the VM"
  type        = string
  default     = "~/.ssh/id_rsa"
}


variable "website_local_dir" {
  type        = string
  default     = "website"
  description = "Absolute or relative path to static site folder"
}


