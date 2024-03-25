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

#######################################################################################
# Create Ingress Service VPC with Gateway and Network Load Balancer for Inbound Access
#######################################################################################

module "ingress-service-vpc" {
  depends_on             = [aws_ec2_transit_gateway.tgw]
  source                 = "./modules/service-vpc"
  env_name               = var.env_name
  ciscomcd_account       = var.ciscomcd_account
  ingress_egress         = "ingress" # must be "ingress" or "egress"
  aws_region             = var.aws_region
  vpc_cidr               = "10.101.0.0/16" # must be cidr address with mask ex: "10.100.0.0/16"
  aws_availability_zones = var.aws_availability_zones
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  use_nat_gateway        = false # must be bool - true or false - use nat gw for egress
  gateway_instance_type  = var.gateway_instance_type # size of instance ex: "AWS_M5_LARGE"
  aws_min_instances      = var.aws_min_instances # auto-scaling minimum # of instances deployed
  aws_max_instances      = var.aws_max_instances # auto-scaling maximum # of instances deployed
  aws_iam_role           = var.aws_iam_role # permission for gateway to integrate with other aws resources
  gateway_image          = var.gateway_image # gateway image version ex: "23.08-14"
  ssh_key_pair           = aws_key_pair.public_key.key_name # key created above in resource "aws_key_pair" "public_key"
  aws_gateway_lb         = false # must be bool - true for egress - false for ingress
}

##############################################
# Create a Spoke VPC for the Yelb Application
##############################################

module "yelb-vpc" {
  depends_on             = [module.egress-service-vpc, module.ingress-service-vpc]
  source                 = "./modules/spoke-vpc"
  env_name               = var.env_name
  app_name               = "yelb"
  vpc_cidr               = "10.1.0.0/16"
  aws_availability_zones = var.aws_availability_zones
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  egress_service_vpc_id  = module.egress-service-vpc.service_vpc_id
  ingress_service_vpc_id = module.ingress-service-vpc.service_vpc_id
}

##############################################
# Create a Spoke VPC for EKS Applications
##############################################

module "eks-vpc" {
  depends_on             = [module.egress-service-vpc, module.ingress-service-vpc]
  source                 = "./modules/spoke-vpc"
  env_name               = var.env_name
  app_name               = "eks"
  vpc_cidr               = "10.2.0.0/16"
  aws_availability_zones = var.aws_availability_zones
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  egress_service_vpc_id  = module.egress-service-vpc.service_vpc_id
  ingress_service_vpc_id = module.ingress-service-vpc.service_vpc_id
}

##################################################
# Create a Yelb Application on EC2 Running Docker
##################################################

module "yelb-app" {
  depends_on             = [module.yelb-vpc]
  source                 = "./modules/standard-lb-app"
  env_name               = var.env_name
  app_name               = "yelb"
  app_service            = "8080"
  app_protocol           = "TCP"
  spoke_vpc_id           = module.yelb-vpc.spoke_vpc_id
  spoke_subnets          = module.yelb-vpc.spoke_subnets
  aws_availability_zones = var.aws_availability_zones
  instance_image         = "DockerCompose-Ubuntu-*"
  instance_type          = "t2.medium"
  ssh_key_pair           = var.ssh_key_pair
  user_data              = <<-EOT
  #!/bin/bash
  git clone https://github.com/emcnicholas/demo-kind-yelb.git
  cd demo-kind-yelb/
  sudo docker compose up -d
  docker ps
  EOT
}

##################################################
# Create a EKS Cluster with ALB Controller
##################################################

module "eks-cluster" {
  depends_on = [module.eks-vpc]
  source = "./modules/eks-cluster"
  env_name = var.env_name
  spoke_subnets = module.eks-vpc.spoke_subnets
  instance_types = "t3.small"
  eks_desired_nodes = 3
  eks_max_nodes = 4
  eks_min_nodes = 1
  aws_account = var.aws_account
  aws_region = var.aws_region
  spoke_vpc_id = module.eks-vpc.spoke_vpc_id
}

####################################################
# Create Sock Shop Microservices App on EKS Cluster
####################################################

#module "sock-shop" {
#  depends_on = [module.eks-cluster]
#  source = "./modules/eks-app"
#  spoke_subnets = module.eks-vpc.spoke_subnets
#}
