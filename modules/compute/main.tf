# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# EC2 Web Server Instance
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = var.public_subnets[0]
  
  vpc_security_group_ids = [var.ec2_sg_id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              
              cat > /var/www/html/index.html << 'HTML'
              <!DOCTYPE html>
              <html lang="en">
              <head>
                  <meta charset="UTF-8">
                  <meta name="viewport" content="width=device-width, initial-scale=1.0">
                  <title>DDoS Protected Demo - AWS WAF & CloudFront</title>
                  <style>
                      * { margin: 0; padding: 0; box-sizing: border-box; }
                      body {
                          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                          min-height: 100vh;
                          display: flex;
                          align-items: center;
                          justify-content: center;
                          color: white;
                          padding: 20px;
                      }
                      .container {
                          background: rgba(255, 255, 255, 0.15);
                          backdrop-filter: blur(10px);
                          border: 1px solid rgba(255, 255, 255, 0.2);
                          padding: 50px;
                          border-radius: 20px;
                          box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
                          max-width: 900px;
                          width: 100%;
                      }
                      h1 { font-size: 3em; margin-bottom: 20px; text-align: center; text-shadow: 2px 2px 4px rgba(0,0,0,0.3); }
                      .subtitle { text-align: center; font-size: 1.2em; margin-bottom: 30px; opacity: 0.9; }
                      .badges { display: flex; justify-content: center; flex-wrap: wrap; gap: 10px; margin-bottom: 30px; }
                      .badge {
                          background: rgba(76, 175, 80, 0.3);
                          border: 1px solid rgba(76, 175, 80, 0.5);
                          padding: 8px 16px;
                          border-radius: 20px;
                          font-size: 0.9em;
                          font-weight: 600;
                      }
                      .info-box {
                          background: rgba(0, 0, 0, 0.2);
                          padding: 25px;
                          border-radius: 12px;
                          margin: 25px 0;
                          border-left: 4px solid #4CAF50;
                      }
                      .info-box h3 { margin-bottom: 15px; font-size: 1.3em; }
                      .info-box p { margin: 10px 0; padding-left: 10px; line-height: 1.6; }
                      .test-section {
                          text-align: center;
                          margin-top: 35px;
                          padding-top: 30px;
                          border-top: 1px solid rgba(255, 255, 255, 0.2);
                      }
                      .test-section h3 { font-size: 1.5em; margin-bottom: 15px; }
                      .test-description { margin: 15px 0 25px; opacity: 0.9; line-height: 1.6; }
                      .button-group { display: flex; justify-content: center; flex-wrap: wrap; gap: 15px; margin-bottom: 25px; }
                      button {
                          background: #4CAF50;
                          color: white;
                          border: none;
                          padding: 16px 30px;
                          border-radius: 8px;
                          font-size: 16px;
                          font-weight: 600;
                          cursor: pointer;
                          transition: all 0.3s ease;
                          box-shadow: 0 4px 6px rgba(0, 0, 0, 0.2);
                          min-width: 180px;
                      }
                      button:hover { background: #45a049; transform: translateY(-2px); box-shadow: 0 6px 12px rgba(0, 0, 0, 0.3); }
                      button:active { transform: translateY(0); }
                      button:disabled { background: #999; cursor: not-allowed; transform: none; }
                      #result {
                          margin-top: 25px;
                          padding: 25px;
                          background: rgba(0, 0, 0, 0.3);
                          border-radius: 10px;
                          min-height: 100px;
                          line-height: 1.8;
                      }
                      .protected { color: #4CAF50; font-weight: bold; font-size: 1.1em; }
                      .warning { color: #FFC107; font-weight: bold; }
                      .progress { color: #2196F3; font-weight: bold; }
                      @media (max-width: 768px) {
                          .container { padding: 30px 20px; }
                          h1 { font-size: 2em; }
                          button { width: 100%; margin: 8px 0; }
                      }
                  </style>
              </head>
              <body>
                  <div class="container">
                      <h1>🛡️ DDoS Protection Demo</h1>
                      <p class="subtitle">Enterprise-Grade AWS Security Architecture</p>
                      
                      <div class="badges">
                          <span class="badge">✅ Terraform IaC</span>
                          <span class="badge">✅ CloudFront CDN</span>
                          <span class="badge">✅ AWS WAF</span>
                          <span class="badge">✅ Auto-Response</span>
                      </div>
                      
                      <div class="info-box">
                          <h3>🔒 Active Protection Layers:</h3>
                          <p>✅ <strong>CloudFront CDN:</strong> 450+ edge locations absorb traffic globally</p>
                          <p>✅ <strong>AWS WAF:</strong> Web Application Firewall with custom rules</p>
                          <p>✅ <strong>Rate Limiting:</strong> Blocks IPs exceeding 2000 requests/5min</p>
                          <p>✅ <strong>Bot Detection:</strong> Identifies automated attack tools</p>
                          <p>✅ <strong>OWASP Top 10:</strong> SQL injection, XSS, CSRF protection</p>
                          <p>✅ <strong>Emergency Response:</strong> Lambda auto-activates stricter rules</p>
                      </div>
                      
                      <div class="info-box">
                          <h3>📊 Protection Workflow:</h3>
                          <p><strong>1.</strong> Traffic hits CloudFront first (450+ global locations)</p>
                          <p><strong>2.</strong> WAF inspects every request against 5 rule sets</p>
                          <p><strong>3.</strong> Rate limiting tracks requests per IP address</p>
                          <p><strong>4.</strong> CloudWatch monitors blocked request metrics</p>
                          <p><strong>5.</strong> Alarm triggers if >100 blocks/min for 2 minutes</p>
                          <p><strong>6.</strong> Lambda function reduces rate limit to 100/5min</p>
                          <p><strong>7.</strong> Email notification sent with attack details</p>
                      </div>
                      
                      <div class="test-section">
                          <h3>🧪 Test Rate Limiting Protection</h3>
                          <p class="test-description">
                              Send multiple requests to test the WAF rate limiting.<br>
                              After ~2000 requests, WAF will block your IP for 5 minutes!
                          </p>
                          
                          <div class="button-group">
                              <button onclick="test(100)">100 Requests</button>
                              <button onclick="test(500)">500 Requests</button>
                              <button onclick="test(2500)">2500 Requests</button>
                          </div>
                          
                          <div id="result">
                              <p style="opacity: 0.7; text-align: center;">
                                  👆 Click a button above to start testing
                              </p>
                          </div>
                      </div>
                  </div>
                  
                  <script>
                      let testing = false;
                      
                      async function test(count) {
                          if (testing) {
                              alert('Test already in progress!');
                              return;
                          }
                          
                          testing = true;
                          const buttons = document.querySelectorAll('button');
                          buttons.forEach(btn => btn.disabled = true);
                          
                          const result = document.getElementById('result');
                          result.innerHTML = '<p class="progress">🔄 <strong>Testing with ' + count + ' requests...</strong></p>';
                          
                          let allowed = 0, blocked = 0;
                          const startTime = Date.now();
                          
                          for (let i = 0; i < count; i++) {
                              try {
                                  const response = await fetch('/', { method: 'HEAD', cache: 'no-store' });
                                  response.ok ? allowed++ : blocked++;
                              } catch { blocked++; }
                              
                              if ((i + 1) % 50 === 0) {
                                  const elapsed = ((Date.now() - startTime) / 1000).toFixed(1);
                                  const progress = Math.round(((i + 1) / count) * 100);
                                  result.innerHTML = '<p class="progress"><strong>Progress: ' + progress + '%</strong></p>' +
                                      '<p>✅ Allowed: ' + allowed + ' | 🚫 Blocked: ' + blocked + '</p>' +
                                      '<p>⏱️ Time: ' + elapsed + 's</p>';
                              }
                          }
                          
                          const totalTime = ((Date.now() - startTime) / 1000).toFixed(1);
                          const blockRate = ((blocked / count) * 100).toFixed(1);
                          
                          result.innerHTML = '<strong>✅ Test Complete!</strong><br><br>' +
                              '📊 Total: ' + count + ' requests<br>' +
                              '✅ Allowed: ' + allowed + '<br>' +
                              '🚫 Blocked: ' + blocked + ' (' + blockRate + '%)<br>' +
                              '⏱️ Duration: ' + totalTime + 's<br><br>';
                          
                          if (blocked > 0) {
                              result.innerHTML += '<span class="protected">🛡️ Rate limiting is working!</span><br>' +
                                  '<small>Your IP was temporarily blocked. Wait 5 minutes to reset.</small>';
                          } else {
                              result.innerHTML += '<span class="warning">⚠️ No blocks yet</span><br>' +
                                  '<small>Try 2500 requests to trigger the rate limit</small>';
                          }
                          
                          testing = false;
                          buttons.forEach(btn => btn.disabled = false);
                      }
                  </script>
              </body>
              </html>
              HTML
              
              systemctl start httpd
              systemctl enable httpd
              EOF

  tags = {
    Name = "${var.project_name}-web-server"
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnets

  tags = {
    Name = "${var.project_name}-load-balancer"
  }
}

# Target Group
resource "aws_lb_target_group" "web" {
  name     = "${var.project_name}-targets"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name = "${var.project_name}-target-group"
  }
}

# Attach EC2 to Target Group
resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web.id
  port             = 80
}

# ALB Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}
