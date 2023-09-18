resource "aws_iam_role" "codebuild" {
  name = "codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "policy" {
  name_prefix = "codebuildpolicy"
  description = "codebuild policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_custom_policy" {
  role       = aws_iam_role.codebuild.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_codebuild_project" "example" {
  name          = var.name
  # name          = "test-project"
  description   = var.description
  # description   = "test_codebuild_project"
  build_timeout = var.build_timeout
  # build_timeout = "5"
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    type = var.artifacts_type
    # type = "NO_ARTIFACTS"
  }

  # cache {
  #   type     = "S3"
  #   location = aws_s3_bucket.example.bucket
  # }

  environment {
    compute_type                = var.compute_type
    # compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = var.image
    # image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = var.environment_type
    # type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = var.image_pull_credentials_type
    # image_pull_credentials_type = "CODEBUILD"

    dynamic "environment_variable" {
      for_each = var.environment_variables

      content {
        name  = environment_variable.value.name
        value = environment_variable.value.name
        type  = environment_variable.value.type
      }
    }
    # environment_variable {
    #   name  = "SOME_KEY1"
    #   value = "SOME_VALUE1"
    # }

    # environment_variable {
    #   name  = "SOME_KEY2"
    #   value = "SOME_VALUE2"
    #   type  = "PARAMETER_STORE"
    # }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = var.logs_group_name
      # group_name  = "log-group"
      stream_name = var.logs_stream_name
      # stream_name = "log-stream"
    }
  }

  source {
    type            = var.source_type
    # type            = "GITHUB"
    location        = var.source_location
    # location        = "https://github.com/gtorres777/my-react-app"
    git_clone_depth = var.source_git_clone_depth
    # git_clone_depth = 1

    # git_submodules_config {
    #   fetch_submodules = true
    # }
  }

  source_version = var.source_version
  # source_version = "master"

  # vpc_config {
  #   vpc_id = aws_vpc.example.id

  #   subnets = [
  #     aws_subnet.example1.id,
  #     aws_subnet.example2.id,
  #   ]

  #   security_group_ids = [
  #     aws_security_group.example1.id,
  #     aws_security_group.example2.id,
  #   ]
  # }

  tags = {
    Environment = var.environment
  }
}
