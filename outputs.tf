output "application_url" {
  description = "🌐 Your protected website URL"
  value       = "http://${module.security.cloudfront_domain}"
}

output "dashboard_url" {
  description = "📊 CloudWatch monitoring dashboard"
  value       = module.monitoring.dashboard_url
}

output "next_steps" {
  value = <<-EOT
  
  ╔════════════════════════════════════════════════════════════════╗
  ║                  ✅ DEPLOYMENT COMPLETE!                       ║
  ╚════════════════════════════════════════════════════════════════╝
  
  📝 NEXT STEPS:
  1. 🌐 Visit: http://${module.security.cloudfront_domain}
  2. 📧 CHECK EMAIL and confirm SNS subscription (critical!)
  3. 📊 Dashboard: ${module.monitoring.dashboard_url}
  4. 🧪 Test protection using website buttons
  
  💰 COST: ~$10-15 for testing, ~$75-100/month production
  EOT
}
