variable "fmc_username" {
    type = string
}

variable "fmc_password" {
    type = string
    sensitive = true
}

variable "fmc_host" {
    type = string
}

variable "fmc_insecure_skip_verify" {
    type = bool
    default = true
}

variable "ftd_ip" {
  type = string
}
