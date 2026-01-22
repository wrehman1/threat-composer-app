resource "aws_route53_record" "a" {
  zone_id = var.zone_id
  name    = var.fqdn
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = var.evaluate_target_health
  }
}

resource "aws_route53_record" "aaaa" {
  count   = var.create_aaaa ? 1 : 0
  zone_id = var.zone_id
  name    = var.fqdn
  type    = "AAAA"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = var.evaluate_target_health
  }
}

