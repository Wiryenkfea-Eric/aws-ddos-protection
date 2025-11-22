output "alb_sg_id" { value = aws_security_group.alb.id }
output "ec2_sg_id" { value = aws_security_group.ec2.id }
output "cloudfront_domain" { value = aws_cloudfront_distribution.main.domain_name }
output "cloudfront_id" { value = aws_cloudfront_distribution.main.id }
output "waf_web_acl_id" { value = aws_wafv2_web_acl.main.id }
output "waf_web_acl_name" { value = aws_wafv2_web_acl.main.name }
