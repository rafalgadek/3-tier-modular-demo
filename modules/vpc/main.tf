resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "${var.project}-${var.env}-vpc"
  }
}

# Subnets

data "aws_availability_zones" "available_zones" {}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  for_each                = var.public_subnet
  cidr_block              = each.value
  availability_zone       = element(data.aws_availability_zones.available_zones.names, (each.key - 1) % length(data.aws_availability_zones.available_zones.names))
  map_public_ip_on_launch = "true"

  tags = {
    Name = "${var.project}-${var.env}-public-subnet-${each.key}"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  for_each          = var.private_subnet_cidr
  cidr_block        = each.value
  availability_zone = element(data.aws_availability_zones.available_zones.names, (each.key - 1) % length(data.aws_availability_zones.available_zones.names))

  tags = {
    Name = "${var.project}-${var.env}-private-subnet-${each.key}"
  }
}

resource "aws_subnet" "db_subnet" {
  vpc_id            = aws_vpc.main.id
  for_each          = var.db_subnet
  cidr_block        = each.value
  availability_zone = element(data.aws_availability_zones.available_zones.names, (each.key - 1) % length(data.aws_availability_zones.available_zones.names))

  tags = {
    Name = "${var.project}-${var.env}-db-subnet-${each.key}"
  }
}

#Internet gateway and routing from public subnets

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project}-${var.env}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project}-${var.env}-public-route-table"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  for_each       = { for i, subnet in aws_subnet.public_subnet : i => subnet }
  subnet_id      = aws_subnet.public_subnet[each.key].id
  route_table_id = aws_route_table.public.id
}

#NAT gateways and routing form private and db subnets

resource "aws_eip" "nat_gateway_eip" {
  for_each = { for i, subnet in aws_subnet.public_subnet : i => subnet }
  vpc      = true
}

resource "aws_nat_gateway" "nat_gateway" {
  for_each      = { for i, subnet in aws_subnet.public_subnet : i => subnet }
  allocation_id = aws_eip.nat_gateway_eip[each.key].id
  subnet_id     = each.value.id
  tags = {
    Name = "${var.project}-${var.env}-nat-gateway-${each.key}"
  }
}

resource "aws_route_table" "private" {
  for_each = { for i, subnet in aws_subnet.private_subnet : i => subnet }
  vpc_id   = aws_vpc.main.id
  tags = {
    Name = "${var.project}-${var.env}-private-route-table-${each.key}"
  }
}

resource "aws_route" "private" {
  for_each               = { for i, subnet in aws_subnet.private_subnet : i => subnet }
  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat_gateway[each.key].id
}

resource "aws_route_table_association" "private" {
  for_each       = { for i, subnet in aws_subnet.private_subnet : i => subnet }
  subnet_id      = aws_subnet.private_subnet[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table_association" "db" {
  for_each       = { for i, subnet in aws_subnet.db_subnet : i => subnet }
  subnet_id      = aws_subnet.db_subnet[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

#Application load balancer

resource "aws_lb" "alb" {
  name               = "alb-public-${var.env}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for value in aws_subnet.public_subnet : value.id]
  tags = {
    Name = "${var.project}-${var.env}-application-load-balancer"
  }
}

resource "aws_lb_listener" "alb" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.alb_listner_port
  protocol          = var.alb_listner_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_servers_tg.arn
  }
}

resource "aws_lb_target_group" "web_servers_tg" {
  name     = "web-servers-tg-${var.env}"
  port     = var.web_servers_tg_listner_port
  protocol = var.web_servers_tg_listner_protocol
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "az_tg" {
  for_each         = { for i, server in var.instance_ids : i => server }
  target_id        = each.value
  target_group_arn = aws_lb_target_group.web_servers_tg.arn
  port             = var.web_servers_tg_listner_port
}

#Security groups

# ALB security group

resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project}-${var.env}-alb-security-group"
  }
}

resource "aws_security_group_rule" "ingress_to_alb_sg" {
  for_each          = var.ingress_rules
  type              = "ingress"
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
  description       = each.key
}

resource "aws_security_group_rule" "egress_from_alb_sg" {
  for_each          = var.egress_rules
  type              = "egress"
  from_port         = each.value
  to_port           = each.value
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
  description       = each.key
}

#Web servers security group

resource "aws_security_group" "web_servers_sg" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project}-${var.env}-web-servers-security-group"
  }
}

resource "aws_security_group_rule" "ingress_to_web_servers_sg" {
  for_each          = var.ingress_rules
  type              = "ingress"
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.web_servers_sg.id
  description       = each.key
}

resource "aws_security_group_rule" "egress_from__sg" {
  for_each          = var.egress_rules
  type              = "egress"
  from_port         = each.value
  to_port           = each.value
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_servers_sg.id
  description       = each.key
}



