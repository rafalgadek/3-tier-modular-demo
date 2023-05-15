module "vpc" {
  source                          = "./modules/vpc"
  env                             = var.env
  region                          = var.region
  project                         = var.project
  vpc_cidr                        = var.vpc_cidr
  public_subnet                   = var.public_subnet
  private_subnet_cidr             = var.private_subnet_cidr
  db_subnet                       = var.db_subnet
  alb_listner_port                = var.alb_listner_port
  alb_listner_protocol            = var.alb_listner_protocol
  web_servers_tg_listner_port     = var.web_servers_tg_listner_port
  web_servers_tg_listner_protocol = var.web_servers_tg_listner_protocol
  ingress_rules                   = var.ingress_rules
  egress_rules                    = var.egress_rules
  instance_ids                    = module.ec2.instance_ids
}

module "ec2" {
  source             = "./modules/ec2"
  env                = var.env
  project            = var.project
  ami                = var.ami
  instance_type      = var.instance_type
  web_servers_sg     = module.vpc.web_servers_sg
  private_subnet_ids = module.vpc.private_subnet_ids
}