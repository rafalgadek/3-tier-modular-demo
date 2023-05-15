output "instance_ids" {
  value = [for server in aws_instance.web_sever : server.id]
}