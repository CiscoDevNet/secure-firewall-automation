######################
# Variable Assignments
######################

# Environment Name - This name will be tagged to all AWS resources
env_name            = ""

# AWS Credentials
aws_access_key      = ""
aws_secret_key      = ""

# AWS Region and Availability Zone
region              = ""
aws_az              = ""

#FMC and FTD Info

# To deploy an FMCv in the mgmt subnet set "create_fmcv" to true. If using cdFMC in CDO set value to false.
# This value must be set!
create_fmcv         = true

# Enter FMC Password if "create_fmcv" is set to true.
fmc_pass            = ""

# FTD password must be entered
ftd_pass            = ""

# Enter cdFMC FQDN if "create_fmcv" is set to false.
cdFMC               = ""
