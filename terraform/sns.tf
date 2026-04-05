resource "aws_sns_topic" "self_heal_sns_topic" {
  name = "self-heal-updates-topic"
}

resource "aws_sns_topic_subscription" "self_heal_sns_subscription" {
  topic_arn = aws_sns_topic.self_heal_sns_topic.arn
  protocol  = "email"
  endpoint  = var.alert_email
}