resource "aws_dynamodb_table" "self_heal_table" {
  name         = "self-heal-incidents"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "incident_id"

  attribute {
    name = "incident_id"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = true
  }

  tags = {
    Name        = "self-heal-incidents-table"
    Environment = "dev"
  }
}

