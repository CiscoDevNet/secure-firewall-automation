// If you dont provide any value, it will take the default value

// Resorce group Location
location = "Central India"

// This would prefix all the component with this string.
prefix = "Cisco-FTDv"

// Limit the Management access to specific source
source_address = "*"

// All the IP Address segment will use this as prefix with .0,.1,.2 and .3 as the 3rd octet
vn_cidr = "10.0.0.0/16"

// FTD Version to be deployed - Please validate the correct version using - 'az vm image list -p cisco -f cisco-ftdv -s ftdv-azure-byol --all'
ftd_image_version = "73069.0.0"
fmc_image_version = "73069.0.0"

// Size of the FTDv to be deployed
vm_size = "Standard_D3_v2"

// Resource Group Name
rg_name = "FTDv-RG"

// Instance Name and properties of FTDv
instancename = "FTDv-1"

// Count of FTDv to be deployed.
instances = 1

// Is true if the ftd is managed by fmc, It creates a fmc
create_fmc = true

create_rg = true
create_vn = true

fmc_password = "Cisco@123"
ftd_password = "Cisco@123"
reg_key      = "cisco"
fmc_nat_id   = "cisco"

fmc_ip = "10.0.2.18"
ftd_mgmt_ip = ["10.0.2.11","10.0.2.12"]
