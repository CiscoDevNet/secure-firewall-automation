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
  content       = tls_private_key.key_pair.private_key_openssh
  filename      = "${var.env-name}-private-key.pem"
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
  key_name   = "${var.env-name}-${random_string.id.result}-key"
  public_key = tls_private_key.key_pair.public_key_openssh
}

###########################################################
# Create AWS Transit Gateway to route traffic between VPCs
###########################################################

# Transit Gateway

resource "aws_ec2_transit_gateway" "tgw" {
  description = "${var.env-name} Transit Gateway"
	default_route_table_association    = "disable"
	default_route_table_propagation    = "disable"
  tags = {
    Name    = "${var.env-name}-tgw"
  }
}
