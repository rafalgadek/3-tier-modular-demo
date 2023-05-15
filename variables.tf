variable "env" {
  description = "environment"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "aws region"
  type        = string
  default     = "eu-central-1"
}

variable "project" {
  description = "project name"
  type        = string
  default     = "3-tier-architecture"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC network range"
  default     = "10.0.0.0/16"
}

variable "public_subnet" {
  type        = map(string)
  description = "each public subnet cidr range and name"
  default = {
    1 : "10.0.0.0/24",
    2 : "10.0.1.0/24"
  }
}

variable "private_subnet_cidr" {
  type        = map(string)
  description = "each private subnet cidr range and number"
  default = {
    1 : "10.0.3.0/24",
    2 : "10.0.4.0/24"
  }
}

variable "db_subnet" {
  type        = map(string)
  description = "each database subnet cidr range and number"
  default = {
    1 : "10.0.5.0/24",
    2 : "10.0.6.0/24"
  }
}

variable "alb_listner_port" {
  type        = string
  description = "application load balancer listner port"
  default     = "80"
}

variable "alb_listner_protocol" {
  type        = string
  description = "application load balancer listner protocol"
  default     = "HTTP"
}

variable "web_servers_tg_listner_port" {
  type        = string
  description = "web serwers target group listner port"
  default     = "80"
}

variable "web_servers_tg_listner_protocol" {
  type        = string
  description = "web serwers target group listner protocol"
  default     = "HTTP"
}

variable "ingress_rules" {
  type        = map(string)
  description = "ingress ports"
  default = {
    "HTTP" : "80",
    "HTTPS" : "443"
  }
}

variable "egress_rules" {
  type        = map(string)
  description = "ingress ports"
  default = {
    "-1" : "0",
  }
}

#EC2

variable "ami" {
  type    = string
  default = "ami-03f255060aa887525"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "web_servers_sg" {
  type        = string
  description = "Web server security group"
  default     = "aws_security_group.web_servers_sg.id"
}



