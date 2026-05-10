output "dynamodb_table_name" {
  value = aws_dynamodb_table.self_heal_table.name
}


output "sns_topic_arn" {
  value = aws_sns_topic.self_heal_sns_topic.arn
}


output "remediation_serv_respository_uri" {
  value = aws_ecr_repository.remediation_serv_repository.repository_url
}


output "app_repository_uri" {
  value = aws_ecr_repository.app_repository.repository_url
}