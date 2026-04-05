output "dynamodb_table_name" {
  value = aws_dynamodb_table.self_heal_table.name
}


output "sns_topic_arn" {
  value = aws_sns_topic.self_heal_sns_topic.arn
}