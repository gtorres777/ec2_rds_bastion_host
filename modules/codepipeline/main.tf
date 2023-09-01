resource "aws_codepipeline" "example" {
  name     = "my-codepipeline"
  role_arn = aws_iam_role.pipeline.arn

  artifact_store {
    location = "my-codepipeline-artifacts"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name            = "SourceAction"
      category        = "Source"
      owner           = "ThirdParty"
      provider        = "GitHub"
      version         = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        Owner      = "your-github-username"
        Repo       = "your-github-repo"
        Branch     = "main"
        OAuthToken = "your-github-oauth-token"
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
      input_artifacts = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]

      configuration = {
        ProjectName = aws_codebuild_project.example.name
      }
    }
  }
}

resource "aws_codebuild_project" "example" {
  name = "my-codebuild-project"

  source {
    type = "NO_SOURCE"
  }

  artifacts {
    type = "CODEPIPELINE"
  }
}

resource "aws_iam_role" "pipeline" {
  name = "my-codepipeline-role"

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

output "codepipeline_id" {
  value = aws_codepipeline.example.id
}
