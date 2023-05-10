output "vpc_id" {
  value = aws_vpc.vpc.id
}
output "sn_private" {
  value = aws_subnet.sn_private[*].id
}
output "sn_public" {
  value = aws_subnet.sn_public[*].id
}
output "sgp_external_lb" {
  value = aws_security_group.sgp_external_lb.id
  depends_on = [ aws_security_group.sgp_external_lb ]
}
output "sgp_internal_lb" {
  value = aws_security_group.sgp_internal_lb.id
}
output "sgp_frontend_instances" {
  value = aws_security_group.sgp_frontend_instances.id
  depends_on = [ aws_security_group.sgp_frontend_instances ]
}
output "sgp_backend_instances" {
  value = aws_security_group.sgp_backend_instances.id
}
output "sgp_database" {
  value = aws_security_group.sgp_database.id
}