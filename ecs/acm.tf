################################
# Locals
################################
locals {
  ecs_acm_name = "${format("%s-%s-alb-acm", var.cluster_name, var.env)}"
}

################
# Route53 
################
data "aws_route53_zone" "zone" {
  name         = "${var.route53_zone_name}"
  private_zone = false
}

################
# ACM
################
resource "aws_acm_certificate" "cert" {
  domain_name       = "${format("*.%s", var.route53_zone_name)}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = "${merge(map("Name", local.ecs_acm_name), var.tags)}"
}

resource "aws_route53_record" "cert_validation" {
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.zone.id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 300
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}
