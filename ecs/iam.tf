################################
# IAM
################################

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
resource "aws_iam_role" "service_task_execution_role" {
  name = "${local.helloworld_ecs_service_name}-${var.region}-${var.env}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF

  tags = "${merge(map("Name", format("%s-%s-role", local.helloworld_ecs_service_name, var.env)), var.tags)}"
}

resource "aws_iam_role_policy_attachment" "service_task_execution_policy" {
  role       = "${aws_iam_role.service_task_execution_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
