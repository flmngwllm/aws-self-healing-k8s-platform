resource "aws_eks_cluster" "self_heal_cluster" {
  name = "self-heal-cluster"

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.self_heal_cluster_role.arn
  version  = "1.31"

  vpc_config {
    subnet_ids = concat(
      values(aws_subnet.self_heal_public_subnet)[*].id,
      values(aws_subnet.self_heal_private_subnet)[*].id
    )
    # Enable both private and public access to the EKS API server
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = {
    Name = "self-heal-cluster"
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.self_heal_cluster_AmazonEKSClusterPolicy,
  ]
}



resource "aws_eks_node_group" "self_heal_node_group" {
  cluster_name    = aws_eks_cluster.self_heal_cluster.name
  node_group_name = "self-heal-node-group"
  node_role_arn   = aws_iam_role.self_heal_node_group_role.arn
  subnet_ids      = values(aws_subnet.self_heal_private_subnet)[*].id
  instance_types  = ["t3.medium"]
  disk_size       = 30

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.self_heal_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.self_heal_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.self_heal_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.self_heal_AmazonSSMManagedInstanceCore
  ]

  tags = {
    Name = "self-heal-node-group"
  }
}


resource "aws_eks_access_entry" "self_heal_gha_access" {
  cluster_name  = aws_eks_cluster.self_heal_cluster.name
  principal_arn = "arn:aws:iam::831274730062:role/self-heal-github-actions-role"
  type          = "STANDARD"

}

resource "aws_eks_access_policy_association" "self_heal_gha_admin" {
  cluster_name  = aws_eks_cluster.self_heal_cluster.name
  principal_arn = "arn:aws:iam::831274730062:role/self-heal-github-actions-role"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.self_heal_gha_access
  ]
}



resource "aws_eks_access_entry" "self_heal_user_access" {
  cluster_name  = aws_eks_cluster.self_heal_cluster.name
  principal_arn = "arn:aws:iam::831274730062:user/self-heal-platform"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "self_heal_user_admin" {
  cluster_name  = aws_eks_cluster.self_heal_cluster.name
  principal_arn = "arn:aws:iam::831274730062:user/self-heal-platform"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.self_heal_user_access]
}

resource "time_sleep" "wait_for_gha_eks_access" {
  depends_on = [
    aws_eks_access_policy_association.self_heal_gha_admin
  ]

  create_duration = "60s"
}

resource "time_sleep" "wait_for_argocd_crds" {
  depends_on = [
    helm_release.self_heal_argocd
  ]

  create_duration = "30s"
}