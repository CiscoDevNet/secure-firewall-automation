#############
# Outputs
#############
# If create_fmcv is TRUE then FMCv set FMCv public IP address. If FALSE set to null
output "fmc_public_ip" {
  value = var.create_fmcv ? aws_eip.fmc-mgmt-EIP[0].public_ip : null
}

output "ftd_public_ip" {
  value = aws_eip.ftd-mgmt-EIP.public_ip
}