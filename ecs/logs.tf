################################
# Cloudwatch Logs
################################

# Set up cloudwatch group and log stream and retain logs for 14 days
resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/ecs/${var.cluster_name}-${var.env}"
  retention_in_days = 14

  tags = "${merge(map("Name", format("%s-%s-log-group", var.cluster_name, var.env)), var.tags)}"
}
