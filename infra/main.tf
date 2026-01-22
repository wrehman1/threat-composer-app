module "vpc" {
  source               = "./modules/vpc"
  name_prefix          = var.name_prefix
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "ecr" {
  source      = "./modules/ecr"
  name_prefix = var.name_prefix
}

data "aws_route53_zone" "primary" {
  name         = var.domain_name
  private_zone = false
}

module "acm" {
  source      = "./modules/acm"
  name_prefix = var.name_prefix

  zone_id     = data.aws_route53_zone.primary.zone_id
  domain_name = var.domain_name
}

module "alb" {
  source      = "./modules/alb"
  name_prefix = var.name_prefix
  
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids

  certificate_arn = module.acm.certificate_arn

  zone_id = data.aws_route53_zone.primary.zone_id
  fqdn    = "${var.domain_name}"

  container_port    = var.container_port
  health_check_path = var.health_check_path
}

module "ecs" {
  source             = "./modules/ecs"
  name_prefix        = var.name_prefix
  environment        = var.environment
  aws_region         = var.aws_region
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  ecr_repo_url   = module.ecr.repository_url
  container_port = var.container_port
  cpu            = var.ecs_cpu
  memory         = var.ecs_memory
  desired_count  = var.desired_count

  target_group_arn      = module.alb.target_group_arn
  alb_security_group_id = module.alb.alb_security_group_id

  ssm_parameters = var.ssm_parameters
}

module "dns" {
  source      = "./modules/dns"
  name_prefix = var.name_prefix

  zone_id      = data.aws_route53_zone.primary.zone_id
  fqdn         = "${var.domain_name}"
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id

  create_aaaa = false
}