output "eks-cluster-endpoint" {
  value = aws_eks_cluster.eks-cluster.endpoint
}
output "eks-cluster-certificate_authority" {
  value = aws_eks_cluster.eks-cluster.certificate_authority[0].data
}