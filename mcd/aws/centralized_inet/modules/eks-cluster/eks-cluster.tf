terraform {
  required_providers {
    ciscomcd = {
      source = "CiscoDevNet/ciscomcd"
      version = "0.2.4"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">=2.26.0"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.12.1"
    }
  }
}

# EKS Cluster

resource "aws_iam_role" "eks-role" {
  name = "${var.env_name}-eks_cluster_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-role.name
}

resource "aws_eks_cluster" "eks-cluster" {
  name     = "${var.env_name}-cluster"
  role_arn = aws_iam_role.eks-role.arn

  vpc_config {
    subnet_ids = [for subnet in var.spoke_subnets : subnet.id]
  }

  depends_on = [aws_iam_role_policy_attachment.AmazonEKSClusterPolicy]

  tags = {
    Name    = "${var.env_name}-cluster"
    prefix = var.env_name
    app  = "eks"
  }
}

# EKS Node Group

resource "aws_iam_role" "nodes" {
  name = "${var.env_name}-eks-node-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

resource "aws_eks_node_group" "private-nodes" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "${var.env_name}-private-nodes"
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids = [for subnet in var.spoke_subnets : subnet.id]

  capacity_type  = "ON_DEMAND"
  instance_types = [var.instance_types]

  scaling_config {
    desired_size = var.eks_desired_nodes
    max_size     = var.eks_max_nodes
    min_size     = var.eks_min_nodes
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }
  tags = {
    Name    = "${var.env_name}-private-nodes"
    prefix = var.env_name
    app  = "eks"
  }

  # taint {
  #   key    = "team"
  #   value  = "devops"
  #   effect = "NO_SCHEDULE"
  # }

  # launch_template {
  #   name    = aws_launch_template.eks-with-disks.name
  #   version = aws_launch_template.eks-with-disks.latest_version
  # }

  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly
  ]
}

# resource "aws_launch_template" "eks-with-disks" {
#   name = "eks-with-disks"

#   key_name = "local-provisioner"

#   block_device_mappings {
#     device_name = "/dev/xvdb"

#     ebs {
#       volume_size = 50
#       volume_type = "gp2"
#     }
#   }
# }

# OpenID connect provider

data "tls_certificate" "eks" {
  url = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}

#resource "kubectl_manifest" "config_map_aws_auth" {
#  depends_on = [ciscomcd_gateway.egress-gateway]
#  yaml_body = <<YAML
#apiVersion: v1
#kind: ConfigMap
#metadata:
#  name: aws-auth
#  namespace: kube-system
#data:
#  mapRoles: |
#    - rolearn: ${aws_iam_role.nodes.arn}
#      username: system:node:{{EC2PrivateDNSName}}
#      groups:
#        - system:bootstrappers
#        - system:nodes
#YAML
#}

# IAM Assume Role to allow IAM User to access EKS Cluster
data "aws_iam_policy_document" "kubectl_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.aws_account}:root"]
    }
  }
}

resource "aws_iam_role" "eks_kubectl_role" {
  name               = "example-kubectl-access-role"
  assume_role_policy = data.aws_iam_policy_document.kubectl_assume_role_policy.json
}
resource "aws_iam_role_policy_attachment" "eks_kubectl-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_kubectl_role.name
}
resource "aws_iam_role_policy_attachment" "eks_kubectl-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_kubectl_role.name
}
resource "aws_iam_role_policy_attachment" "eks_kubectl-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_kubectl_role.name
}

# AWS Application Load Balancer Controller

module "lb_role" {
 source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

 role_name                              = "${var.env_name}_eks_lb"
 attach_load_balancer_controller_policy = true

 oidc_providers = {
     main = {
     provider_arn               = aws_iam_openid_connect_provider.eks.arn
     namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
     }
 }
 }

resource "time_sleep" "wait_30_seconds" {
  depends_on = [aws_eks_node_group.private-nodes]
  create_duration = "30s"
}

resource "kubernetes_service_account" "service-account" {
  depends_on = [time_sleep.wait_30_seconds]
 metadata {
     name      = "aws-load-balancer-controller"
     namespace = "kube-system"
     labels = {
     "app.kubernetes.io/name"      = "aws-load-balancer-controller"
     "app.kubernetes.io/component" = "controller"
     }
     annotations = {
     "eks.amazonaws.com/role-arn"               = module.lb_role.iam_role_arn
     "eks.amazonaws.com/sts-regional-endpoints" = "true"
     }
 }
 }

resource "helm_release" "alb-controller" {
 name       = "aws-load-balancer-controller"
 repository = "https://aws.github.io/eks-charts"
 chart      = "aws-load-balancer-controller"
 namespace  = "kube-system"
 depends_on = [
     kubernetes_service_account.service-account
 ]

 set {
     name  = "region"
     value = var.aws_region
 }

 set {
     name  = "vpcId"
     value = var.spoke_vpc_id
 }

 set {
     name  = "image.repository"
     value = "602401143452.dkr.ecr.${var.aws_region}.amazonaws.com/amazon/aws-load-balancer-controller"
 }

 set {
     name  = "serviceAccount.create"
     value = "false"
 }

 set {
     name  = "serviceAccount.name"
     value = "aws-load-balancer-controller"
 }

 set {
     name  = "clusterName"
     value = aws_eks_cluster.eks-cluster.name
 }
}