#######################
# Device Registration
#######################

# Enable License for FMCv
resource "fmc_smart_license" "license" {
  count = var.create_fmcv ? 1 : 0
  registration_type = "EVALUATION"
}

# Create default Access Control Policy
resource "fmc_access_policies" "access_policy" {
  depends_on = [fmc_smart_license.license]
  name           = "FTDv-Access-Policy"
  default_action = "block"
}

## Register Device to FMC
resource "fmc_devices" "ftd" {
  depends_on = [fmc_access_policies.access_policy]
  name = "FTDv"
  hostname = local.ftd_mgmt_ip
  regkey = var.ftd_reg_key
  nat_id = var.ftd_nat_id
  performance_tier = var.ftd_performance_tier
  license_caps = [
    "BASE",
    "MALWARE",
    "URLFilter",
    "THREAT"]
  access_policy {
    id = fmc_access_policies.access_policy.id
    type = "AccessPolicy"
    }
  cdo_host = "www.defenseorchestrator.com"
  cdo_region = var.cdo_region
}