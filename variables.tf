variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix for all resources"
  type        = string
  default     = "ddos-demo"
}

variable "alert_email" {
  description = "Email address for attack notifications"
  type        = string
}

variable "rate_limit" {
  description = "WAF rate limit - requests per 5 minutes per IP"
  type        = number
  default     = 2000
}

variable "emergency_rate_limit" {
  description = "Emergency rate limit during active attacks"
  type        = number
  default     = 100
}
