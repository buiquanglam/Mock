#get dns_name of load balancer application
output "lb_dns" {
  value       = aws_lb.web-lb.dns_name
  description = "Web LB domain name"
}
