variable "name_prefix" { type = string }
variable "environment" { type = string }

variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }

variable "ecr_repo_url" { type = string }
variable "container_port" { type = number }

variable "cpu" { type = number }
variable "memory" { type = number }

variable "desired_count" { type = number }

variable "target_group_arn" { type = string }

variable "alb_security_group_id" {
  description = "ALB SG id so ECS can allow inbound from ALB"
  type        = string
}

variable "ssm_parameters" {
  type    = map(string)
  default = {}
}

variable "aws_region" {
  type        = string
  description = "AWS region for CloudWatch logs"
}
