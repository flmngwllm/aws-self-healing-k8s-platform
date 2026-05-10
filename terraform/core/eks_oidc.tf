resource "aws_iam_openid_connect_provider" "self_heal_api_eks_oidc" {
  url             = aws_eks_cluster.self_heal_cluster.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0ecd2e0e0"]
  depends_on      = [aws_eks_cluster.self_heal_cluster]
}