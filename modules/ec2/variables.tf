variable "env" {
  description = "environment"
  type        = string
}

variable "project" {
  description = "project name"
  type        = string
}

variable "ami" {
  type        = string
  description = "AMI amazon machine image"
}

variable "instance_type" {
  type        = string
  description = "amazon instance type"
}

variable "web_servers_sg" {
  type        = string
  description = "Web server security group"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "private subnet ids"
}

