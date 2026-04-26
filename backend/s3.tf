resource "aws_s3_bucket" "self_heal_terraform_state" {
  bucket = "self-heal-terraform-state"

  tags = {
    Project = "self-heal-eks"
    Purpose = "Terraform State Storage"
  }

}

resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.self_heal_terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state_encryption" {
  bucket = aws_s3_bucket.self_heal_terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket                  = aws_s3_bucket.self_heal_terraform_state.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}