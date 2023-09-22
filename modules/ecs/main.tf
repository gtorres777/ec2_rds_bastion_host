resource "aws_ecs_cluster" "default" {
  name  = var.cluster_name
  # name  = "NEXTCLOUDCLUSTER"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "project" {
  count           = var.create ? 1 : 0
  name            = "${var.service_name}"
  # name            = "ecs-service-nextcloud"
  cluster         = aws_ecs_cluster.default.arn
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.project[0].arn
  desired_count   = var.desired_tasks

  enable_execute_command = true

  network_configuration {
    security_groups = [aws_security_group.allow-custom-alb.id]
    subnets         = var.private_subnets
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "ecs-${var.service_name}-container"
    # container_name   = "ecs-nextcloud-container"
    container_port   = var.task_web_port
  }

  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"

  # workaround for https://github.com/hashicorp/terraform/issues/12634
  depends_on = [ var.alb,
      aws_ecs_task_definition.project
    ]

}

module "ecs_security_group" {
  create      = var.create ? true : false
  source      = "terraform-aws-modules/security-group/aws"
  version     = "4.17.1"
  name        = "${var.service_name}-sg"
  description = "Default security group for ${var.service_name}"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = var.leadgenius_cidrs
  ingress_with_cidr_blocks = [
    {
      from_port   = var.task_web_port
      to_port     = var.task_web_port
      protocol    = "tcp"
      description = "Custom TCP service port"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 8888
      to_port     = 8888
      protocol    = "tcp"
      description = "Shell Port"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
}

resource "aws_security_group" "allow-custom-alb" {
  vpc_id = var.vpc_id
  name = "ecs-sg"
  description = "security group that allows custom protocols and all egress traffic to ALB"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    description = "VPC"
    cidr_blocks = ["11.0.0.0/16"]
  }

  ingress {
    from_port   = var.task_web_port
    to_port     = var.task_web_port
    protocol    = "tcp"
    description = "Custom TCP service port"
    security_groups = [var.alb_sg_id]
  }

  tags = {
    Name = "allow-custom-alb"
  }
}

### ECS Tasks Execution Role
data "aws_iam_policy_document" "ecs_tasks_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "ecs_tasks_execution_role" {
  name               = "ecsTaskExecution-role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_tasks_execution_role.json}"
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = "${aws_iam_role.ecs_tasks_execution_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_tasks_custom_policy_execution" {
  role       = "${aws_iam_role.ecs_tasks_execution_role.name}"
  policy_arn = aws_iam_policy.policy.arn
}

####
#####


data "aws_iam_policy_document" "ecs_task_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "ecsTask-role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_task_role.json}"
}

resource "aws_iam_policy" "policy" {
  name_prefix = "ecs-task-policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel",
            "ssm:DescribeParameters"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetAuthorizationToken"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = "ecs:ExecuteCommand",
        Resource = "*"
      }
    ]
  })
}



resource "aws_iam_role_policy_attachment" "ecs_tasks_custom_policy" {
  role       = "${aws_iam_role.ecs_task_role.name}"
  policy_arn = aws_iam_policy.policy.arn
}
## END Task Execution Role

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name = "/ecs/${var.service_name}"
  # name = "/ecs/nextcloud"
  retention_in_days = 14
}

resource "aws_ecs_task_definition" "project" {
  count           = var.create ? 1 : 0

  family                   = "${var.service_name}-cloudtask"
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  task_role_arn            = aws_iam_role.ecs_tasks_execution_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024

  container_definitions    = <<TASK_DEFINITION
  [
    {
      "name": "ecs-${var.service_name}-container",
      "image": "${var.image}",
      "essential": true,
      "environment": ${jsonencode(var.environment_variables)},
      "portMappings": [
        {
          "containerPort": ${var.task_web_port},
          "hostPort": ${var.task_web_port}
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.ecs_log_group.name}",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "linuxParameters": {
        "initProcessEnabled": true
      }
    }
  ]
  TASK_DEFINITION
}
#   container_definitions    = <<TASK_DEFINITION
# [
#   {
#     "name": "mysql",
#     "image": "mysql",
#     "environment": [
#       {
#         "name": "MYSQL_ROOT_PASSWORD",
#         "value": "password"
#       },
#       {
#         "name": "MYSQL_DATABASE",
#         "value": "nextcloud"
#       },
#       {
#         "name": "MYSQL_USER",
#         "value": "nextcloud"
#       },
#       {
#         "name": "MYSQL_PASSWORD",
#         "value": "password"
#       }
#     ],
#     "logConfiguration": {
#       "logDriver": "awslogs",
#       "options": {
#         "awslogs-group": "${aws_cloudwatch_log_group.mysql.name}",
#         "awslogs-region": "us-east-1",
#         "awslogs-stream-prefix": "ecs"
#       }
#     }
#   },
#   {
#     "name": "ecs-nextcloud-container",
#     "image": "nextcloud",
#     "essential": true,
#     "portMappings": [
#       {
#         "containerPort": 80,
#         "hostPort": 80
#       }
#     ],
#     "environment": [
#         {
#           "name": "MYSQL_HOST",
#           "value": "db"
#         },
#         {
#           "name": "MYSQL_DATABASE",
#           "value": "nextcloud"
#         },
#         {
#           "name": "MYSQL_USER",
#           "value": "nextcloud"
#         },
#         {
#           "name": "MYSQL_PASSWORD",
#           "value": "password"
#         },
#         {
#           "name": "NEXTCLOUD_TRUSTED_DOMAINS",
#           "value": "cloud.gustavo-td.com"
#         }
#       ],
#     "logConfiguration": {
#       "logDriver": "awslogs",
#       "options": {
#         "awslogs-group": "${aws_cloudwatch_log_group.ecs_log_group.name}",
#         "awslogs-region": "us-east-1",
#         "awslogs-stream-prefix": "ecs"
#       }
#     },
#     "linuxParameters": {
#       "initProcessEnabled": true
#     }
#   }
# ]
# TASK_DEFINITION



