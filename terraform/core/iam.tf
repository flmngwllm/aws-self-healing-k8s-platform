resource "aws_iam_role" "self_heal_cluster_role" {
  name = "self-heal-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}


resource "aws_iam_role_policy_attachment" "self_heal_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.self_heal_cluster_role.name
}


resource "aws_iam_role" "self_heal_node_group_role" {
  name = "eks-node-group-self-heal"

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

resource "aws_iam_role_policy_attachment" "self_heal_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.self_heal_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "self_heal_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.self_heal_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "self_heal_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.self_heal_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "self_heal_AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.self_heal_node_group_role.name
}



resource "aws_iam_role" "self_heal_oidc_role" {
  name = "self-heal-remediation-serv-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = aws_iam_openid_connect_provider.self_heal_api_eks_oidc.arn
        }
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.self_heal_api_eks_oidc.url, "https://", "")}:sub" = "system:serviceaccount:default:remediation-serv-sa"
            "${replace(aws_iam_openid_connect_provider.self_heal_api_eks_oidc.url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}


resource "aws_iam_policy" "self_heal_permissions" {
  name        = "self-heal-oidc-permissions"
  description = "Permissions for Self-Heal via OIDC"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["sns:Publish", "dynamodb:PutItem", "dynamodb:UpdateItem", "dynamodb:Scan"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_oidc" {
  role       = aws_iam_role.self_heal_oidc_role.name
  policy_arn = aws_iam_policy.self_heal_permissions.arn
}