data "aws_iam_openid_connect_provider" "self-heal_github" {
  url = "https://token.actions.githubusercontent.com"
}


resource "aws_iam_role" "self-heal_github_actions" {
  name = "self-heal-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "${data.aws_iam_openid_connect_provider.self-heal_github.arn}"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:flmngwllm/aws-self-healing-k8s-platform:*"
          },
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      },
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:user/self-heal-platform"
        },
        Action = "sts:AssumeRole"
      }

    ]
  })
}

resource "aws_iam_role_policy" "self-heal_github_actions_policy" {
  name = "self-heal-github-actions-policy"
  role = aws_iam_role.self-heal_github_actions.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # --- EKS ---
      {
        Effect = "Allow",
        Action = [
          "eks:ListIdentityProviderConfigs", "eks:ListAddons", "eks:ListClusters", "eks:ListUpdates",
          "eks:ListNodegroups", "eks:DescribeCluster", "eks:DescribeNodegroup", "eks:DescribeAddonVersions",
          "eks:UpdateClusterConfig", "eks:DescribeUpdate", "eks:CreateCluster", "eks:CreateNodegroup",
          "eks:DeleteCluster", "eks:DeleteNodegroup", "eks:CreateAccessEntry", "eks:CreateAccessPolicyAssociation",
          "eks:DeleteAccessEntry", "eks:DescribeAccessEntry", "eks:AssociateAccessPolicy",
          "eks:ListAssociatedAccessPolicies", "eks:DisassociateAccessPolicy", "eks:AccessKubernetesApi"
        ],
        Resource = "*"
      },

      # --- ECR ---
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken", "ecr:BatchCheckLayerAvailability", "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage", "ecr:PutImage", "ecr:DescribeRepositories", "ecr:ListTagsForResource",
          "ecr:CreateRepository", "ecr:TagResource", "ecr:InitiateLayerUpload", "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ],
        Resource = "*"
      },

      # --- TF backend S3/DDB ---
      {
        Effect = "Allow",
        Action = ["s3:GetObject", "s3:PutObject", "s3:ListBucket", "s3:DeleteObject"],
        Resource = [
          "arn:aws:s3:::self-heal-terraform-state",
          "arn:aws:s3:::self-heal-terraform-state/*"
        ]
      },
      {
        Effect   = "Allow",
        Action   = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:DeleteItem", "dynamodb:DescribeTable"],
        Resource = "arn:aws:dynamodb:us-east-1:831274730062:table/self-heal-terraform-locks"
      },

      # --- EC2 for networking ---
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeVpcs", "ec2:DescribeSubnets", "ec2:DescribeSecurityGroups", "ec2:DescribeRouteTables",
          "ec2:DescribeInternetGateways", "ec2:DescribeVpcAttribute", "ec2:DescribeAddresses",
          "ec2:DescribeAddressesAttribute", "ec2:DescribeNatGateways", "ec2:CreateVpc", "ec2:CreateSubnet",
          "ec2:CreateInternetGateway", "ec2:CreateRouteTable", "ec2:CreateRoute", "ec2:CreateSecurityGroup",
          "ec2:CreateNatGateway", "ec2:AttachInternetGateway", "ec2:DeleteInternetGateway", "ec2:AllocateAddress",
          "ec2:AssociateRouteTable", "ec2:ModifyVpcAttribute", "ec2:RevokeSecurityGroupEgress",
          "ec2:DescribeNetworkInterfaces", "ec2:DeleteSecurityGroup", "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress", "ec2:DescribeKeyPairs", "ec2:CreateTags"
        ],
        Resource = "*"
      },

      # --- IAM ---
      {
        Effect = "Allow",
        Action = [
          "iam:GetRole", "iam:GetRolePolicy", "iam:GetOpenIDConnectProvider", "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies", "iam:ListInstanceProfilesForRole", "iam:DetachRolePolicy",
          "iam:DeleteRole", "iam:DeleteOpenIDConnectProvider", "iam:CreateRole", "iam:PassRole", "iam:TagRole",
          "iam:CreateServiceLinkedRole", "iam:ListRoles"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "iam:AttachRolePolicy", "iam:CreatePolicy", "iam:PutRolePolicy", "iam:DeleteRolePolicy", "iam:DeletePolicy",
          "iam:DeletePolicyVersion", "iam:GetPolicy", "iam:GetPolicyVersion", "iam:ListPolicyVersions",
          "iam:CreateOpenIDConnectProvider"
        ],
        Resource = "*"
      },

      # --- SSM Read ---
      {
        Effect   = "Allow",
        Action   = ["ssm:Describe*", "ssm:Get*", "ssm:List*"],
        Resource = "*"
      }
    ]
  })
}