################################
# Locals
################################
locals {
  cw_alarm_name_prefix = "${var.cluster_name}-${var.env}-${local.helloworld_ecs_service_name}"
}

resource "aws_appautoscaling_target" "ecs_auto_scale" {
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"

  min_capacity = "${var.app_count}"
  max_capacity = "${var.max_app_count}"
}

resource "aws_appautoscaling_policy" "scale_up" {
  name               = "scale_up"
  policy_type        = "StepScaling"
  service_namespace  = "${aws_appautoscaling_target.ecs_auto_scale.service_namespace}"
  scalable_dimension = "${aws_appautoscaling_target.ecs_auto_scale.scalable_dimension}"
  resource_id        = "${aws_appautoscaling_target.ecs_auto_scale.resource_id}"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 2
    }
  }
}

resource "aws_appautoscaling_policy" "scale_down" {
  name               = "scale_down"
  policy_type        = "StepScaling"
  service_namespace  = "${aws_appautoscaling_target.ecs_auto_scale.service_namespace}"
  scalable_dimension = "${aws_appautoscaling_target.ecs_auto_scale.scalable_dimension}"
  resource_id        = "${aws_appautoscaling_target.ecs_auto_scale.resource_id}"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

# Cloudwatch alarm that triggers the autoscaling up policy
resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
  alarm_name          = "${local.cw_alarm_name_prefix}-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"

  namespace   = "AWS/ECS"
  metric_name = "CPUUtilization"
  period      = "60"
  statistic   = "Maximum"
  threshold   = "10"

  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
    ServiceName = "${aws_ecs_service.main.name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.scale_up.arn}"]
}

# Cloudwatch alarm that triggers the autoscaling down policy
resource "aws_cloudwatch_metric_alarm" "service_cpu_low" {
  alarm_name          = "${local.cw_alarm_name_prefix}-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"

  namespace   = "AWS/ECS"
  metric_name = "CPUUtilization"
  period      = "60"
  statistic   = "Maximum"
  threshold   = "10"

  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
    ServiceName = "${aws_ecs_service.main.name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.scale_down.arn}"]
}
