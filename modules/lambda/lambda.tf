data "archive_file" "lambda_code" {
  type        = "zip"
  # source_dir  = "${path.module}/read_function_code"
  # output_path = "${path.module}/read_function_code.zip"
  source_dir = "${var.absolute_path}/${var.source_dir}"
  output_path = "${var.absolute_path}/${var.output_path}"
}
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  # name               = "iam_for_lambda-${var.project}-${var.environment}-${var.suffix}-role"
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "iam_lambda_policy" {
  name = var.policy_name
  role = aws_iam_role.iam_for_lambda.id

  # policy = file("policies/readLambda_policy.json")
  policy = file("policies/${var.policy_file_name}")
}

resource "aws_iam_role_policy_attachment" "readLambda_policy" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "lambda_function" {
  function_name    = var.lambda_function_name
  filename         = "${var.absolute_path}/lambdas_code/${var.filename}"
  # runtime          = "nodejs14.x"
  runtime          = var.runtime
  # handler          = "index.handler"
  handler          = var.handler
  role          = aws_iam_role.iam_for_lambda.arn
  source_code_hash = data.archive_file.lambda_code.output_base64sha256
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"
  retention_in_days = 30
}

