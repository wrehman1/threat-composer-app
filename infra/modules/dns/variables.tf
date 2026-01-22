variable "name_prefix" {
  type = string
}

variable "zone_id" {
  description = "Route53 Hosted Zone ID"
  type        = string
}

variable "fqdn" {
  description = "Full record name (tm.mwaqar.co.uk)"
  type        = string
}

variable "alb_dns_name" {
  description = "ALB DNS name (e.g. xxx.elb.amazonaws.com)"
  type        = string
}

variable "alb_zone_id" {
  description = "ALB canonical hosted zone ID"
  type        = string
}

variable "create_aaaa" {
  description = "Also create an AAAA alias record"
  type        = bool
  default     = false
}

variable "evaluate_target_health" {
  type    = bool
  default = true
}

