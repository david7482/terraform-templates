################################
# Locals
################################
locals {
  ecs_alb_name              = "${format("%s-%s-alb", var.cluster_name, var.env)}"
  ecs_alb_listen_http_port  = 80
  ecs_alb_listen_https_port = 443
}

locals {
  ecs_alb_tg_name     = "${format("%s-%s-alb-tg", var.cluster_name, var.env)}"
  ecs_alb_tg_port     = 8080
  ecs_alb_tg_protocol = "HTTP"
}

locals {
  ecs_alb_sg_name = "${format("%s-%s-alb-sg", var.cluster_name, var.env)}"
}

################################
# Subnets
################################
data "aws_subnet_ids" "public" {
  vpc_id = "${var.vpc_id}"

  tags = {
    Purpose = "public-subnet"
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = "${var.vpc_id}"

  tags = {
    Purpose = "private-subnet"
  }
}

################################
# Security Groups
################################
data "aws_security_group" "default" {
  vpc_id = "${var.vpc_id}"
  name   = "default"
}

resource "aws_security_group" "alb-sg" {
  name        = "${local.ecs_alb_sg_name}"
  description = "controls access to the ALB"
  vpc_id      = "${var.vpc_id}"

  ingress {
    protocol    = "tcp"
    from_port   = "${local.ecs_alb_listen_http_port}"
    to_port     = "${local.ecs_alb_listen_http_port}"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = "${local.ecs_alb_listen_https_port}"
    to_port     = "${local.ecs_alb_listen_https_port}"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(map("Name", local.ecs_alb_sg_name), var.tags)}"
}

################################
# Application Load Balancer
################################
resource "aws_alb" "alb" {
  name            = "${local.ecs_alb_name}"
  subnets         = ["${data.aws_subnet_ids.public.ids}"]
  security_groups = ["${aws_security_group.alb-sg.id}", "${data.aws_security_group.default.id}"]

  tags = "${merge(map("Name", local.ecs_alb_name), var.tags)}"
}

resource "random_id" "alb_tg_random" {
  keepers {
    name     = "${local.ecs_alb_tg_name}"
    port     = "${local.ecs_alb_tg_port}"
    protocol = "${local.ecs_alb_tg_protocol}"
    vpc_id   = "${var.vpc_id}"
  }

  byte_length = 2
}

resource "aws_alb_target_group" "alb_tg" {
  name                 = "${local.ecs_alb_tg_name}-${random_id.alb_tg_random.hex}"
  port                 = "${local.ecs_alb_tg_port}"
  protocol             = "${local.ecs_alb_tg_protocol}"
  vpc_id               = "${var.vpc_id}"
  deregistration_delay = 60
  target_type          = "ip"

  health_check {
    healthy_threshold   = "3"
    unhealthy_threshold = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "5"
    path                = "${var.health_check_path}"
  }

  # To achieve zero downtime when we update this target group
  lifecycle {
    create_before_destroy = true
  }

  # Avoid error: The target group does not have an associated load balancer.
  depends_on = [
    "aws_alb.alb",
  ]

  tags = "${merge(map("Name", local.ecs_alb_tg_name), var.tags)}"
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = "${aws_alb.alb.id}"
  port              = "${local.ecs_alb_listen_http_port}"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.alb_tg.id}"
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = "${aws_alb.alb.id}"
  port              = "${local.ecs_alb_listen_https_port}"
  protocol          = "HTTPS"
  certificate_arn   = "${aws_acm_certificate_validation.cert.certificate_arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.alb_tg.id}"
  }
}

################################
# Route53
################################
resource "aws_route53_record" "alb_record" {
  zone_id = "${data.aws_route53_zone.zone.id}"
  name    = "${format("helloecs.%s", var.route53_zone_name)}"
  type    = "A"

  alias {
    evaluate_target_health = true
    name                   = "${aws_alb.alb.dns_name}"
    zone_id                = "${aws_alb.alb.zone_id}"
  }
}
