#########################
# Variable Assignments
#########################

# Environment Name - This name will be tagged to all AWS resources
env_name = "Pod-#"

# To deploy an FMCv in the mgmt subnet set "create_fmcv" to true. If using cdFMC in CDO set value to false.
# This value must be set!
create_fmcv   = false

# Enter FMC Password if "create_fmcv" is set to true.
fmc_pass      = "123Cisco@123!"

# Enter cdFMC FQDN if "create_fmcv" is set to false.
cdFMC         = ""

# Enter CDO Token if "create_fmcv" is set to false.
cdo_token     = ""

# Enter the CDO region of your CDO SaaS instance (us, eu, apj).
cdo_region    = "us"

# Enter FMC Public IP from Network Output if using FMCv. If using cdFMC leave empty "".
fmc_public_ip = ""

# Enter the FTD Public IP address from the Network Output.
ftd_mgmt_public_ip = ""

# ftd reg key and nat id are needed for both FMCv and cdFMC deployments
ftd_reg_key = "cisco"
ftd_nat_id  = "abc123"