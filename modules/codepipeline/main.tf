resource "aws_iam_role" "codepipeline" {
  name = "codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "policy" {
  name_prefix = "codepipelinepolicy"
  description = "codepipeline policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
            "codebuild:StartBuild"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
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
        Action = [
          "codestar-connections:UseConnection"
        ],
        Resource = "*",
        Effect = "Allow"
      },
      {
        Action = [
          "ec2:*",
          "autoscaling:*",
          "cloudwatch:*",
          "s3:*",
          "sns:*",
          "cloudformation:*",
          "rds:*",
          "sqs:*",
          "ecs:*"
        ],
        Resource = "*",
        Effect = "Allow"
      },
      {
        Effect = "Allow",
        Action = [
            "ssm:GetParameters"
        ],
        Resource = "*"
        # Resource = "arn:aws:ssm:${var.aws_region}:${var.account_id}:parameter/leadgenius/${var.project}*${var.environment}*"
      },
      {
        Effect = "Allow",
        Action = [
            "kms:Decrypt"
        ],
        Resource = [
            "*"
            # "arn:aws:ssm:${var.aws_region}:${var.account_id}:key/*"
        ]
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
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_custom_policy" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = aws_iam_policy.policy.arn
}


resource "aws_codepipeline" "codepipeline" {
  name     = var.name
  # name     = "my-codepipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = var.s3_bucket
    # location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  dynamic "stage" {
    for_each = var.stages

    content {
      name  = stage.value.name

      dynamic "action"{
        for_each = stage.value.action

        content {
          name              = action.value.name
          category          = action.value.category
          owner             = action.value.owner
          provider          = action.value.provider
          version           = action.value.version

          input_artifacts   = action.value.input_artifacts
          output_artifacts  = action.value.output_artifacts
          role_arn          = action.value.role_arn
          run_order         = action.value.run_order
          region            = action.value.region
          namespace         = action.value.namespace
          configuration     = action.value.configuration
        }

      }

    }

  }

  tags = {
    Environment = var.environment
  }
}

