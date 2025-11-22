Enterprise-Grade DDoS Protection with Terraform and AWS

A complete, automated, infrastructure-as-code implementation of DDoS protection on AWS using Terraform.
This project deploys a robust defensive architecture combining CloudFront, AWS WAF, ALB, EC2, SNS alerts, and an emergency-response Lambda that dynamically tightens rate limits during active attacks.

It serves both as a hands-on learning environment and as a reusable template for production systems.

Architecture Overview

<img width="800" height="533" alt="image" src="https://github.com/user-attachments/assets/f0b6a243-5247-4944-943f-5497cb308806" />



What this project delivers
1. Fully Protected Public Website

Amazon Linux 2023 EC2 instance

Automated Apache installation and fully styled demo page

Application Load Balancer

CloudFront distribution for global caching and DDoS absorption

2. Multi-Layered AWS WAF Protection

Rate-based rule limiting requests per IP

AWS Managed Rule Groups (Common Rule Set, Bot Control, Anonymous IP List)

Custom bad-bot detection (User-Agent inspection)

3. Monitoring and Alerting

SNS email alerts on abnormal traffic spikes

CloudWatch alarms monitoring blocked requests

CloudWatch dashboard output for real-time visibility

4. Automated Emergency Response

A Lambda function automatically reduces the WAF rate limit when an attack is detected:

CloudWatch alarm fires

SNS triggers the Lambda

Lambda lowers rate limit from 2000 to 100

System immediately enters defensive mode

Prerequisites

Before deploying, ensure you have:

Active AWS account

AWS CLI configured (aws configure)

Terraform 1.0 or higher

Git installed

Verified SNS email subscription

Deployment Instructions

Run the following:

terraform init
terraform validate
terraform apply -auto-approve


Terraform will output:

Public Application URL

CloudWatch Dashboard URL

SNS Topic ARN

WAF WebACL ID and Name

Important:
Confirm the SNS subscription email immediately after deployment.
Without confirmation, alarms and the emergency response automation will not function.

Testing the DDoS Protection
1. Rate Limiting Test

Navigate to your deployed website and use the built-in buttons:

100 requests

500 requests

2500 requests (should trigger rate limit blocks)

2. Bot Detection Test

Run the following:

curl -I https://YOUR-CLOUDFRONT-DOMAIN
curl -I -A "curl-bot" https://YOUR-CLOUDFRONT-DOMAIN


The second request should be blocked by the WAF bot rule.

3. Emergency Response Test

After generating high request volume:

Wait 1–2 minutes

Open AWS WAF console

Inspect the RateLimit rule

You should see the threshold updated to 100 requests / 5 minutes.

Troubleshooting
Issue	Possible Cause	Solution
Website is blank	Apache not finished installing	Wait 1–2 minutes
No SNS email received	Email not verified or in spam	Check spam; confirm subscription
Terraform apply fails	Incorrect AWS CLI credentials	Re-run aws configure
Cleanup (Avoid Unnecessary Charges)

To delete all deployed resources:

terraform destroy -auto-approve


Wait until the terminal confirms: Destroy complete.
