resource "aws_cloudwatch_event_rule" "console" {
  name        = "capture-freeablememory"
  description = "stop dms task"

  event_pattern = jsonencode({
    "source": ["aws.cloudwatch"],
    "detail-type": ["CloudWatch Alarm State Change"],
    "resources": ["arn:aws:cloudwatch:us-east-1:111355452311:alarm:awsrds-premiere-prod-Low-Freeable-Memory"]
    # "detail": {
    #     "state": {
    #         "value": [
    #             "ALARM"
    #         ]
    #     }
    # }
  })
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.console.name
  target_id = "stopdmstasklambda"
  # arn       = aws_sns_topic.aws_logins.arn
  arn       = var.target_arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  # function_name = aws_lambda_function.test_lambda.function_name
  function_name = var.lambda_name
  principal     = "events.amazonaws.com"
  # source_arn    = "arn:aws:events:us-east-1:111355452311:rule/aearule"
  source_arn    = aws_cloudwatch_event_rule.console.arn
}
