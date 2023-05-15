resource "aws_instance" "web_sever" {
  for_each               = { for i, subnet in var.private_subnet_ids : i => subnet }
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.web_servers_sg]
  subnet_id              = each.value
  user_data              = file("./modules/ec2/scripts/user_data.sh")
  tags = {
    Name = "${var.project}-${var.env}-web-server-${each.key}"
  }
}