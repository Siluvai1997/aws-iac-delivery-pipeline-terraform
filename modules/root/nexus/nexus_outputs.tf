output "lb_dns" {
  value = aws_lb.nexus_loadbalancer.dns_name
}