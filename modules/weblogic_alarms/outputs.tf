output "cpu_util_critical_alarm" {
  value = aws_cloudwatch_metric_alarm.cpu_util_critical_alarm.arn
}

output "cpu_util_warning_alarm" {
  value = aws_cloudwatch_metric_alarm.cpu_util_warning_alarm.arn
}

output "healthy_hosts_fatal_alarm" {
  value = aws_cloudwatch_metric_alarm.healthy_hosts_fatal_alarm.arn
}

output "healthy_hosts_warning_alarm" {
  value = aws_cloudwatch_metric_alarm.healthy_hosts_warning_alarm.arn
}

output "heap_usage_critical_alarm" {
  value = aws_cloudwatch_metric_alarm.heap_usage_critical_alarm.arn
}

output "heap_usage_warning_alarm" {
  value = aws_cloudwatch_metric_alarm.heap_usage_warning_alarm.arn
}
