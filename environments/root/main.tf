# module "lambda-dms-stop-tasks" {
#   source = "../../modules/lambda"

#   absolute_path = "/home/circleci/project/environments/root"
#   source_dir = "lambdas_code/dms_stop_tasks/code"
#   output_path = "lambdas_code/dms_stop_tasks/code.zip"
#   lambda_function_name = "dms_stop_tasks"
#   # filename = "dms_stop_tasks/code/code.zip"
#   filename = "dms_stop_tasks/code.zip"
#   runtime = "python3.8"
#   handler = "main.lambda_handler"
#   policy_name = "dms_stop_tasks_policy"
#   policy_file_name = "dms-stop-tasks.json"

# }

data "archive_file" "lambda_code" {
  type        = "zip"
  # source_dir  = "${path.module}/read_function_code"
  # output_path = "${path.module}/read_function_code.zip"
  source_dir = var.source_dir
  output_path = var.output_path
}

# module "alarm" {
#   source = "../../modules/alarms"

#   alarm_name                = "awsrds-premiere-prod-Low-Freeable-Memory"
#   comparison_operator       = "LessThanOrEqualToThreshold"
#   evaluation_periods        = 1
#   metric_name               = "FreeableMemory"
#   namespace                 = "AWS/RDS"
#   period                    = 300
#   statistic                 = "Average"
#   # threshold                 = 64424509440.0
#   threshold                 = 173020518
# }
