variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "alb_dns_name" {
  type = string
}

variable "alb_arn" {
  type = string
}

variable "rate_limit" {
  type = number
}

variable "emergency_rate_limit" {
  type = number
}

variable "alert_topic_arn" {
  type = string
}
