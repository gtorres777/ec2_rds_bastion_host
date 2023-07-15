locals {
  source_code = "${var.relative_path}/${var.source_dir}/code/python/main.py"
  source_code_hash = filebase64sha256(local.source_code)
}
# data "archive_file" "canary_lambda" {
#   type        = "zip"
#   output_path = "/tmp/canary_lambda_${local.source_code_hash}.zip"

#   source {
#     content  = local.source_code
#     filename = "nodejs/node_modules/heartbeat.js"
#   }
# }


# data "archive_file" "canary_function" {
#   type = "zip"
#   source {
#     content  = file(var.canary_source)
#     filename = length(regexall(".*python.*", var.canary_runtime)) > 0 ? "python/canary.py" : "nodejs/node_modules/canary.js"
#   }
#   // canary resource will not detect if file content has changed. So include hash in filename.
#   output_path = "${path.root}/canary-${filemd5(var.canary_source)}.zip"
# }


data "archive_file" "canary_code" {
  type        = "zip"
  source_dir = "${var.relative_path}/${var.source_dir}/code"
  output_path = "${var.relative_path}/${var.output_path}/${local.source_code_hash}.zip"
}

resource "aws_synthetics_canary" "canary" {
  name                 = "nextcloud"
  artifact_s3_location = "s3://cwt-syn-results-881422822893-us-east-1/canary/us-east-1/nextcloud"
  # artifact_s3_location = "s3://cw-syn-results-111355452311-us-east-1/canary/us-east-1/nextcloud-f4f-8c47b1d4a285"
  execution_role_arn   = aws_iam_role.canary_role.arn
  handler              = "main.handler"
  zip_file             = data.archive_file.canary_code.output_path
  # zip_file             = "${var.canaries_code_directory}/code.zip"
  runtime_version      = "syn-python-selenium-1.3"
  start_canary = true
  schedule {
    expression = "rate(5 minutes)"
  }

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
  name               = "canaryExecution-role"
  assume_role_policy = "${data.aws_iam_policy_document.canary_execution_role.json}"
}


resource "aws_iam_role_policy_attachment" "canary_custom_policy" {
  role       = "${aws_iam_role.canary_role.name}"
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_policy" "policy" {
  name_prefix = "canary-task-policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
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
