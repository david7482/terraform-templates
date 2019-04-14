[
  {
    "name": "web",
    "image": "${app_image}",
    "essential": true,
    "cpu": ${fargate_cpu},
    "memory": ${fargate_memory},
    "networkMode": "awsvpc",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_log_group}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "${aws_log_prefix}"
      }
    },
    "portMappings": [
      {
        "containerPort": ${app_port}
      }
    ],
    "ulimits": [
      {
        "name": "nofile",
        "hardLimit": 102400,
        "softLimit": 102400
      }
    ]
  }
]
