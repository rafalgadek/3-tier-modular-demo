output "private_subnet_ids" {
  value = [for subnet in aws_subnet.private_subnet : subnet.id]
}

output "web_servers_sg" {
  description = "Web server security group"
  value       = aws_security_group.web_servers_sg.id
}

