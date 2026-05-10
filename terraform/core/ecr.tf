

resource "aws_ecr_repository" "remediation_serv_repository" {
  name                 = "self-heal-remediation-serv"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = "self-heal-remediation-serv"
  }
}

resource "aws_ecr_repository" "app_repository" {
  name                 = "self-heal-app"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = "self-heal-app"
  }
}

