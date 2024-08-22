# resource "aws_cloudwatch_metric_alarm" "CPUUtilization" {
#   alarm_name                = "test-cpu-alarm"
#   comparison_operator       = "GreaterThanOrEqualToThreshold"
#   evaluation_periods        = "5"
#   metric_name               = "CPUUtilization"
#   namespace                 = "AWS/RDS"
#   period                    = "30"
#   statistic                 = "Maximum"
#   threshold                 = "50"
#   alarm_description         = "This metric monitors RDS CPU utilization"
#   alarm_actions             = [aws_sns_topic.test_cloudwatch_updates.arn]
#   insufficient_data_actions = []

#   dimensions = {
#       DBInstanceIdentifier = "var.db_instance_id"
#    }
# }

resource "aws_cloudwatch_log_group" "log-group" {
  name = "myapp-logs"

  tags = {
    Name = "${var.app_name}-bastion-host-root-volume"
    Environment = "${var.app_env}-bastion-host-root-volume"
  }
}

resource "aws_sns_topic" "test_cloudwatch_updates" {
  name = "test-cloudwatch-notifications"
}

resource "aws_sns_topic_subscription" "cloudwatch_email_sub" {
  topic_arn = aws_sns_topic.test_cloudwatch_updates.arn
  protocol  = "email"
  endpoint  = "rongbattustyle@gmail.com"
}
