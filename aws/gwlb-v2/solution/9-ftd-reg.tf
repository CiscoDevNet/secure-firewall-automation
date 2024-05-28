resource "fmc_devices" "ftd" {
    name = "${var.env_name}-FTDv"
    hostname = aws_instance.ftd.public_ip
    regkey = var.fmc_reg_key
    nat_id = var.fmc_nat_id
    performance_tier = var.ftd_performance_tier
    license_caps = [
      "BASE",
      "MALWARE",
      "URLFilter",
      "THREAT"]
    access_policy {
        id = fmc_access_policies.access_policy.id
    }
}