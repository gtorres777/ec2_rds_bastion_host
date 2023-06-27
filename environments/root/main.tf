module "lambda-dms-stop-tasks" {
  source = "../../modules/lambda"

  absolute_path = "/home/circleci/project/environments/root"
  source_dir = "lambdas_code/dms_stop_tasks/code"
  output_path = "lambdas_code/dms_stop_tasks/code.zip"
  lambda_function_name = "dms_stop_tasks"
  # filename = "dms_stop_tasks/code/code.zip"
  filename = "dms_stop_tasks/code.zip"
  runtime = "python3.8"
  handler = "main.lambda_handler"
  policy_name = "dms_stop_tasks_policy"
  policy_file_name = "dms-stop-tasks.json"

}
