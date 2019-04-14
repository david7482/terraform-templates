################################
# Locals
################################
locals {
  helloworld_ecs_td_name      = "helloworld-http-task"
  helloworld_ecs_service_name = "helloworld-http-task-service"
}

################################
# ECS Task Definition
################################
data "template_file" "helloworld_http" {
  template = "${file("templates/helloworld-http.json.tpl")}"

  vars {
    aws_region     = "${var.region}"
    aws_log_group  = "${aws_cloudwatch_log_group.log_group.name}"
    aws_log_prefix = "${local.helloworld_ecs_service_name}"
    fargate_cpu    = "${var.fargate_cpu}"
    fargate_memory = "${var.fargate_memory}"
    app_image      = "${var.app_image}"
    app_port       = "${var.app_port}"
  }
}

module "container_definition_helloworld_http" {
  source = "github.com/cloudposse/terraform-aws-ecs-container-definition"

  container_name   = "web"
  container_image  = "${var.app_image}"
  essential        = "true"
  container_cpu    = "${var.fargate_cpu}"
  container_memory = "${var.fargate_memory}"
  log_driver       = "awslogs"

  log_options = {
    awslogs-group         = "${aws_cloudwatch_log_group.log_group.name}"
    awslogs-region        = "${var.region}"
    awslogs-stream-prefix = "${local.helloworld_ecs_service_name}"
  }

  port_mappings = [
    {
      containerPort = "${var.app_port}"
      protocol      = "tcp"
    },
  ]

  ulimits = [
    {
      name      = "nofile"
      hardLimit = 102400
      softLimit = 102400
    },
  ]
}

resource "aws_ecs_task_definition" "helloworld_http" {
  family = "${local.helloworld_ecs_td_name}"

  //  task_role_arn       = "${var.ecs_task_execution_role}"
  execution_role_arn       = "${aws_iam_role.service_task_execution_role.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"
  container_definitions    = "${module.container_definition_helloworld_http.json}"
}

################################
# ECS
################################
resource "aws_ecs_cluster" "main" {
  name = "${var.cluster_name}-${var.env}"
  tags = "${merge(map("Name", var.cluster_name), var.tags)}"
}

resource "aws_ecs_service" "main" {
  name             = "${local.helloworld_ecs_service_name}"
  cluster          = "${aws_ecs_cluster.main.id}"
  task_definition  = "${aws_ecs_task_definition.helloworld_http.arn}"
  desired_count    = "${var.app_count}"
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  network_configuration {
    security_groups  = ["${data.aws_security_group.default.id}"]
    subnets          = ["${data.aws_subnet_ids.private.ids}"]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.alb_tg.id}"
    container_name   = "web"
    container_port   = "${var.app_port}"
  }

  lifecycle {
    # Allow external changes without Terraform plan difference
    ignore_changes = ["desired_count"]

    # Create new service first to avoid downtime
    create_before_destroy = true
  }

  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"
  tags                    = "${merge(map("Name", local.helloworld_ecs_service_name), var.tags)}"
}
