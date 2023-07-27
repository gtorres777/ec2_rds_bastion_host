locals {
  source_code = "${var.relative_path}/${var.source_dir}/code/python/main.py"
  # source_code = "/home/circleci/project/${var.relative_path}/${var.source_dir}/code/python/main.py"
  source_code_hash = filebase64sha256(local.source_code)
}

data "archive_file" "canary_code" {
  type        = "zip"
  source_dir = "${var.relative_path}/${var.source_dir}/code"
  output_path = "${var.relative_path}/${var.source_dir}/${local.source_code_hash}.zip"
  # source_dir = "/home/circleci/project/${var.relative_path}/${var.source_dir}/code"
  # output_path = "/home/circleci/project/${var.relative_path}/${var.source_dir}/${local.source_code_hash}.zip"
}

resource "aws_security_group" "canary_sg" {
  name   = "canary-${var.canary_name}-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.private_subnet_cidr
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = ["${var.alb_security_group_id}"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.canary_name}-sg"
  }
}

resource "aws_synthetics_canary" "canary" {
  name                 = "${var.canary_name}"
  artifact_s3_location = "${var.artifact_s3_location}"
  # artifact_s3_location = "s3://cwt-syn-results-881422822893-us-east-1/canary/us-east-1/nextcloud"
  # artifact_s3_location = "s3://cw-syn-results-111355452311-us-east-1/canary/us-east-1/nextcloud-f4f-8c47b1d4a285"
  execution_role_arn   = aws_iam_role.canary_role.arn
  handler              = "${var.handler}"
  zip_file             = data.archive_file.canary_code.output_path
  runtime_version      = "${var.runtime_version}"
  start_canary = var.start_canary

  schedule {
    expression = "${var.expression}"
  }

  vpc_config {
    subnet_ids         = var.private_subnets_ids
    security_group_ids = [aws_security_group.canary_sg.id]
  }

  depends_on = [
      aws_iam_role.canary_role
    ]

}

data "aws_iam_policy_document" "canary_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "canary_role" {
  name               = "canaryExecution-${var.canary_name}-role"
  assume_role_policy = "${data.aws_iam_policy_document.canary_execution_role.json}"
}

resource "aws_iam_role_policy_attachment" "vpc_canary_policy" {
  role       = aws_iam_role.canary_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "canary_custom_policy" {
  role       = "${aws_iam_role.canary_role.name}"
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_policy" "policy" {
  name_prefix = "canary-${var.canary_name}-task-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
            "s3:PutObject",
            "s3:GetObject"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetBucketLocation"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "SNS:Publish",
          "SNS:GetTopicAttributes",
          "SNS:SetTopicAttributes",
          "SNS:Subscribe",
          "SNS:ListSubscriptionsByTopic",
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListAllMyBuckets",
          "xray:PutTraceSegments"
        ],
        Resource = "*"
      },
      {
          Effect = "Allow",
          Resource = "*",
          Action = "cloudwatch:PutMetricData",
          Condition = {
              StringEquals = {
                  "cloudwatch:namespace": "CloudWatchSynthetics"
              }
          }
      }
    ]
  })
}
