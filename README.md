<img width="1536" height="1024" alt="ChatGPT Image Nov 22, 2025, 04_52_40 AM" src="https://github.com/user-attachments/assets/59edb585-2fe4-4df8-969c-ce78b730e961" />


*Enterprise-Grade DDoS Protection with Terraform and AWS*

A fully automated, infrastructure-as-code setup for building, testing, and monitoring DDoS protection in AWS using Terraform.

This project deploys a production-grade architecture that combines AWS WAF, CloudFront, ALB, EC2, SNS alerts, and an automated emergency response Lambda that dynamically lowers rate limits during attacks.

It is designed as a hands-on learning lab and a template you can adapt to enterprise environments.


What this project does

✔️ Creates a fully protected public website

Amazon Linux 2023 EC2 instance

Automatic Apache installation & styled test page

Application Load Balancer

CloudFront distribution in front for global caching & DDoS absorption

✔️ Adds multi-layered DDoS protection

AWS WAF rate-based rules

AWS Managed rules (Common, Bot Control, Anonymous IP, etc.)

Bad bot detection (curl/user-agent match)

✔️ Deploys monitoring & alerting

SNS email notifications

CloudWatch metrics & alarms

CloudWatch dashboard link output

✔️ Auto-responds to live attacks

When CloudWatch detects a spike in blocked requests:
→ SNS triggers Lambda
→ Lambda automatically lowers rate limit from 2000 → 100
→ Immediate defense tightening


Prerequisites

AWS Account

AWS CLI configured (aws configure)

Terraform ≥ 1.0

Git

Verified SNS email subscription

Deployment

terraform init
terraform validate
terraform apply -auto-approve


Once done, Terraform outputs:

-Application URL

-CloudWatch Dashboard

-SNS Topic ARN

-WebACL ID & Name

Open your email and confirm the SNS subscription, otherwise alerts and Lambda triggers will not work.

Testing the DDoS Protection
1. Rate Limit Test

On the deployed website, use the testing buttons:

100 requests

500 requests

2500 requests (expected to trigger blocks)

2. Bot Detection Test
curl -I https://YOUR-CLOUDFRONT-DOMAIN
curl -I -A "curl-bot" https://YOUR-CLOUDFRONT-DOMAIN


The second request should be blocked.

3. Emergency Response Test

After triggering rate-limit blocks:

Wait 1–2 minutes

Check WAF console → "RateLimit" rule

You should see the new threshold: 100 requests / 5 minutes

Troubleshooting
- Issue	Solution
- Website blank	Wait 1–2 mins for Apache install to finish
- No email received	Check spam; SNS sometimes delays initial confirmation
- Terraform fails	Ensure credentials are configured properly


Destroy All Resources (Avoid charges)
terraform destroy -auto-approve


Ensure destruction completes fully before closing terminal.

