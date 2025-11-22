data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  vpc_id      = var.vpc_id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2-sg"
  vpc_id      = var.vpc_id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_cloudfront_distribution" "main" {
  enabled = true
  origin {
    domain_name = var.alb_dns_name
    origin_id   = "alb-origin"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "alb-origin"
    viewer_protocol_policy = "allow-all"
    forwarded_values {
      query_string = true
      cookies { forward = "all" }
    }
    min_ttl = 0
    default_ttl = 0
    max_ttl = 0
  }
  restrictions {
    geo_restriction { restriction_type = "none" }
  }
  viewer_certificate { cloudfront_default_certificate = true }
  web_acl_id = aws_wafv2_web_acl.main.arn
}

resource "aws_wafv2_web_acl" "main" {
  name  = "${var.project_name}-waf"
  scope = "CLOUDFRONT"

  # FIX: Expanded to multiple lines
  default_action {
    allow {}
  }

  # FIX: Expanded to multiple lines
  rule {
    name     = "RateLimit"
    priority = 0
    statement {
      rate_based_statement {
        limit              = var.rate_limit
        aggregate_key_type = "IP"
      }
    }
    action {
      block {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimit"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "BlockBadBots"
    priority = 1
    statement {
      byte_match_statement {
        search_string = "curl"
        field_to_match {
          single_header { name = "user-agent" }
        }
        text_transformation {
          priority = 0
          type     = "LOWERCASE"
        }
        positional_constraint = "CONTAINS"
      }
    }
    action {
      block {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockBadBots"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 2
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesAnonymousIpList"
    priority = 4
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesAnonymousIpList"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesAnonymousIpList"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "main-web-acl"
    sampled_requests_enabled   = true
  }
}
