output "db_endpoint" {
  value = "${aws_db_instance.sonarqube_db.endpoint}"
}

output "lb_dns" {
  value = "${aws_lb.sonarqube_loadbalancer.dns_name}"
}