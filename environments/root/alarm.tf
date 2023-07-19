module "alarm" {
  source = "../../modules/alarms"

  alarm_name                = "Synthetics-Alarm-nextcloud"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "Failed"
  namespace                 = "CloudWatchSynthetics"
  period                    = 900
  statistic                 = "Sum"
  threshold                 = 2.0
  dimensions_name            = "CanaryName"
  dimensions_value           = module.canary.cloudwatch_canary.name
  alarm_actions = [module.snstux.aws_sns_topic_arn]

  depends_on = [
    module.canary
  ]
}
