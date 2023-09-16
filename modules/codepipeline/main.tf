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

data "aws_codestarconnections_connection" "tux_connection" {
  arn = "arn:aws:codestar-connections:us-east-1:111355452311:connection/623d5ea1-9523-4a02-b393-a9e655f1cc1a"
}

resource "aws_codepipeline" "example" {
  name     = "my-codepipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = var.s3_bucket
    # location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name            = "Source"
      category        = "Source"
      owner           = "AWS"
      provider        = "CodeStarSourceConnection"
      version         = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        ConnectionArn    = data.aws_codestarconnections_connection.tux_connection.arn
        FullRepositoryId = "gtorres777/my-react-app"
        BranchName       = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "BuildAction"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]

      configuration = {
        ProjectName = var.aws_codebuild_project_name
      }
    }
  }
}

