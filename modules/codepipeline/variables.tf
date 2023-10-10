variable "name" {
  type        = string
  description = "The name of the codepipeline"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "s3_bucket" {
  type        = string
  description = "The s3 bucket name where AWS CodePipeline stores artifacts for a pipeline"
}

variable "stages" {
  description = "List of stages within the codepipeline, for reference go to https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html#action-requirements"
  type = list(object({
    name        = string
    action      = list(object({
      name             = string
      category         = string
      owner            = string
      provider         = string
      version          = string
      input_artifacts  = optional(list(string))
      output_artifacts = optional(list(string))
      role_arn         = optional(string)
      run_order        = optional(number)
      region           = optional(string)
      namespace        = optional(string)
      configuration    = optional(map(string))
    }))
  }))
}
