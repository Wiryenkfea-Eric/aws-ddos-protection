data "aws_caller_identity" "current" {}

resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "ddos_detected" {
  alarm_name          = "${var.project_name}-ddos-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = "60"
  statistic           = "Sum"
  threshold           = "100"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    WebACL = var.waf_web_acl_name
    Region = "us-east-1"
    Rule   = "ALL"
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../../lambda/emergency_response.py"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_iam_role" "lambda" {
  name = "${var.project_name}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "lambda" {
  name = "${var.project_name}-lambda-policy"
  role = aws_iam_role.lambda.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["wafv2:GetWebACL", "wafv2:UpdateWebACL", "logs:*"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "response" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project_name}-emergency-response"
  role             = aws_iam_role.lambda.arn
  handler          = "emergency_response.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.9"
  environment {
    variables = {
      WEB_ACL_ID   = var.waf_web_acl_id
      WEB_ACL_NAME = var.waf_web_acl_name
    }
  }
}

resource "aws_lambda_permission" "sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.response.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alerts.arn
}

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.response.arn
}
