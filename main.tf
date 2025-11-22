terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "networking" {
  source       = "./modules/networking"
  project_name = var.project_name
}

module "compute" {
  source         = "./modules/compute"
  project_name   = var.project_name
  vpc_id         = module.networking.vpc_id
  public_subnets = module.networking.public_subnets
  alb_sg_id      = module.security.alb_sg_id
  ec2_sg_id      = module.security.ec2_sg_id
}

module "security" {
  source               = "./modules/security"
  project_name         = var.project_name
  vpc_id               = module.networking.vpc_id
  alb_dns_name         = module.compute.alb_dns_name
  alb_arn              = module.compute.alb_arn
  rate_limit           = var.rate_limit
  emergency_rate_limit = var.emergency_rate_limit
  alert_topic_arn      = module.monitoring.alert_topic_arn
}

module "monitoring" {
  source           = "./modules/monitoring"
  project_name     = var.project_name
  alert_email      = var.alert_email
  waf_web_acl_id   = module.security.waf_web_acl_id
  waf_web_acl_name = module.security.waf_web_acl_name
  cloudfront_id    = module.security.cloudfront_id
}
