variable "name" {
  type        = string
  description = "Name for the codebuild project"
}

variable "description" {
  type        = string
  default     = null
  description = "Short description of the project"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "build_timeout" {
  type        = string
  default     = "5"
  description = "Number of minutes for AWS CodeBuild to wait until timing out any related build that does not get marked as completed"
}

variable "artifacts_type" {
  type        = string
  description = "Build output artifact's type. Valid values are CODEPIPELINE, NO_ARTIFACTS, S3"
}

variable "compute_type" {
  type        = string
  description = "Information about the compute resources the build project will use"
}

variable "image" {
  type        = string
  description = "Docker image to use for this build project"
}

variable "environment_type" {
  type        = string
  description = "Type of build environment to use for related builds"
}

variable "image_pull_credentials_type" {
  type        = string
  default     = "CODEBUILD"
  description = "Type of credentials AWS CodeBuild uses to pull images in your build"
}

variable "environment_variables" {
  description = "List of environment variables for the codebuild project"
  default     = null
  type        = list(object({
    name  = string
    value = string
    type  = optional(string)
  }))
}

variable "logs_group_name" {
  type        = string
  description = "Group name of the logs in CloudWatch Logs."
}

variable "logs_stream_name" {
  type        = string
  description = "Stream name of the logs in CloudWatch Logs"
}

variable "source_type" {
  type        = string
  description = "Type of repository that contains the source code to be built. Valid values"
}

variable "source_location" {
  type        = string
  description = "Location of the source code from git or s3"
}

variable "source_git_clone_depth" {
  type        = number
  default     = 1
  description = "depth of commits git history when cloning the repository"
}

variable "source_version" {
  type        = string
  description = "Version of the build input to be built for this project. If not specified, the latest version is used"
}

