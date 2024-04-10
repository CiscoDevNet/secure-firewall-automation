########################################
# Create Key Pair for SSH to Instances
########################################

# Create a UserKeyPair for EC2 instance
resource "tls_private_key" "key_pair" {
  # algorithm = "RSA"
  # rsa_bits  = 4096
  algorithm = "ED25519"
}

# Save the private key on local file
resource "local_file" "this" {
  content         = tls_private_key.key_pair.private_key_openssh
  filename        = "${var.env_name}-private-key.pem"
  file_permission = 0600
}

# Random string for public key name
resource "random_string" "id" {
  length      = 4
  min_numeric = 4
  special     = false
  lower       = true
}

# Save the public key on AWS
resource "aws_key_pair" "public_key" {
  key_name   = "${var.env_name}-${random_string.id.result}-key"
  public_key = tls_private_key.key_pair.public_key_openssh
}

###########################################################
# Create AWS Transit Gateway to route traffic between VPCs
###########################################################

# Transit Gateway

resource "aws_ec2_transit_gateway" "tgw" {
  description                          = "${var.env_name} Transit Gateway"
	default_route_table_association    = "disable"
	default_route_table_propagation    = "disable"
  tags                                 = {
    Name                               = "${var.env_name}-tgw"
  }
}

#########################################################################
# Create Egress Service VPC with Gateway for Centralized Internet Access
#########################################################################

module "egress-service-vpc" {
  depends_on             = [aws_ec2_transit_gateway.tgw]
  source                 = "./modules/service-vpc"
  env_name               = var.env_name
  ciscomcd_account       = var.ciscomcd_account
  ingress_egress         = "egress" # must be "ingress" or "egress"
  aws_region             = var.aws_region
  vpc_cidr               = "10.100.0.0/16" # must be cidr address with mask ex: "10.100.0.0/16"
  aws_availability_zones = var.aws_availability_zones
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  use_nat_gateway        = true # must be bool - true or false - use nat gw for egress
  gateway_instance_type  = var.gateway_instance_type # size of instance ex: "AWS_M5_LARGE"
  aws_min_instances      = var.aws_min_instances # auto-scaling minimum # of instances deployed
  aws_max_instances      = var.aws_max_instances # auto-scaling maximum # of instances deployed
  aws_iam_role           = var.aws_iam_role # permission for gateway to integrate with other aws resources
  gateway_image          = var.gateway_image # gateway image version ex: "23.08-14"
  ssh_key_pair           = aws_key_pair.public_key.key_name # key created above in resource "aws_key_pair" "public_key"
  aws_gateway_lb         = true # must be bool - true for egress - false for ingress
}

##############################################
# Create a Spoke VPC for the Yelb Application
##############################################

module "yelb-vpc" {
  depends_on             = [module.egress-service-vpc]
  source                 = "./modules/spoke-vpc"
  env_name               = var.env_name
  app_name               = "yelb"
  ciscomcd_account       = var.ciscomcd_account
  vpc_cidr               = "10.1.0.0/16"
  aws_availability_zones = var.aws_availability_zones
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  egress_service_vpc_id  = module.egress-service-vpc.service_vpc_id
  ssh_key_pair           = aws_key_pair.public_key.key_name # key created above in resource "aws_key_pair" "public_key"
  app_service_port       = "8080"
  aws_iam_role           = var.aws_iam_role
  aws_region             = var.aws_region
  external_ips           = var.external_ips
  gateway_instance_type  = var.gateway_instance_type # size of instance ex: "AWS_M5_LARGE"
  gateway_image          = var.gateway_image # gateway image version ex: "23.08-14"
}
