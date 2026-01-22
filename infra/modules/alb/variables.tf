variable "name_prefix" { type = string }

variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }

variable "certificate_arn" { type = string }

variable "container_port" {
  type    = number
  default = 3000
}

variable "health_check_path" {
  type    = string
  default = "/health"
}

variable "zone_id" {
  type        = string
  description = "Route 53 Hosted Zone ID"
}

variable "fqdn" {
  type        = string
  description = "Fully qualified domain name for the ALB (e.g. app.example.com)"
}
