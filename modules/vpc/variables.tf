variable "env" {
  description = "environment"
  type        = string
}

variable "region" {
  description = "aws region"
  type        = string
}

variable "project" {
  description = "project name"
  type        = string
}

variable "vpc_cidr" {
  type        = string
  description = "VPC network range"
}

variable "public_subnet" {
  type        = map(string)
  description = "each public subnet cidr range and number"
}

variable "private_subnet_cidr" {
  type        = map(string)
  description = "each public subnet cidr range and number"
}

variable "db_subnet" {
  type        = map(string)
  description = "each database subnet cidr range and number"
}

#ALB

variable "alb_listner_port" {
  type        = string
  description = "application load balancer listner port"
}

variable "alb_listner_protocol" {
  type        = string
  description = "application load balancer listner protocol"
}

variable "web_servers_tg_listner_port" {
  type        = string
  description = "web serwers target group listner port"
}

variable "web_servers_tg_listner_protocol" {
  type        = string
  description = "web serwers target group listner protocol"
}

variable "ingress_rules" {
  type        = map(string)
  description = "ingress ports"
}

variable "egress_rules" {
  type        = map(string)
  description = "egress ports"
}

variable "instance_ids" {
  type        = list(string)
  description = "instance ids for alb target group"
}






