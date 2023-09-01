resource "aws_cloudwatch_metric_alarm" "foobar" {
  alarm_name                = var.alarm_name
  comparison_operator       = var.comparison_operator
  evaluation_periods        = var.evaluation_periods
  metric_name               = var.metric_name
  namespace                 = var.namespace
  period                    = var.period
  statistic                 = var.statistic
  threshold                 = var.threshold
  alarm_actions       = "${var.alarm_actions}"
  ok_actions       = "${var.ok_actions}"

  # dimensions = {
  #   DBInstanceIdentifier = "rds-prod"
  # }

  dimensions = {
    "${var.dimensions_name}" = "${var.dimensions_value}"
  }
}

# resource "aws_cloudwatch_metric_alarm" "foobar" {
#   alarm_name                = var.alarm_name
#   comparison_operator       = var.comparison_operator
#   evaluation_periods        = var.evaluation_periods
#   metric_name               = var.metric_name
#   namespace                 = var.namespace
#   period                    = var.period
#   statistic                 = var.statistic
#   threshold                 = var.threshold

#   threshold_metric_id       = var.threshold_metric_id
#   dynamic "metric_query" {
#     for_each                = var.metric_queries

#     content {
#       id                    = metric_query.value.id
#       expression            = metric_query.value.expression
#       return_data           = metric_query.value.return_data

#       dynamic "metric" {
#         for_each              = metric_query.value.metric

#         content {
#           metric_name         = metric.value.metric_name
#           namespace           = metric.value.namespace
#           period              = metric.value.period
#           stat                = metric.value.statistic
#         }
#       }
#     }
#   }

#   alarm_actions             = "${var.alarm_actions}"
#   ok_actions                = "${var.ok_actions}"

#   dimensions = {
#     "${var.dimensions_name}" = "${var.dimensions_value}"
#   }
# }
