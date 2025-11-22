output "dashboard_url" {
  value = "https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#metricsV2:graph=~(metrics~(~(~'AWS*2fWAFV2~'BlockedRequests~'WebACL~'${var.waf_web_acl_name}~'Region~'us-east-1~'Rule~'ALL))"
}
output "alert_topic_arn" { value = aws_sns_topic.alerts.arn }
