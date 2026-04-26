resource "aws_dynamodb_table" "self_heal_terraform_locks" {
  name         = "self-heal-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  server_side_encryption {
    enabled = true
  }
  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
  Name        = "self-heal-terraform-locks"
  Project     = "self-heal-platform"
  Environment = "bootstrap"
}
}