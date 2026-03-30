resource "aws_ecr_repository" "self_heal_repository" {
  name                 = "self_heal_repository"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = "self_heal_repository"
  }
}

