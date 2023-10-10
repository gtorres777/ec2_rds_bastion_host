resource "aws_cloudwatch_metric_alarm" "foobar" {

  alarm_name                = var.alarm_name
  comparison_operator       = var.comparison_operator
  evaluation_periods        = var.evaluation_periods

  metric_name = var.metric_name
  namespace   = var.namespace
  period      = var.period
  statistic   = var.statistic
  threshold   = var.threshold

  threshold_metric_id   = var.threshold_metric_id 

  dynamic "metric_query" {
    for_each = var.use_metric_query ? var.metric_queries : []

    content {
      id          = metric_query.value.id
      expression  = metric_query.value.expression
      label       = metric_query.value.label
      return_data = metric_query.value.return_data

      dynamic "metric" {
        for_each = can(metric_query.value.metric) ? [metric_query.value.metric] : []

        content {
          metric_name = can(metric.value.metric_name) ? metric.value.metric_name : null
          namespace   = can(metric.value.namespace) ? metric.value.namespace : null
          period      = can(metric.value.period) ? metric.value.period : null
          stat        = can(metric.value.stat) ? metric.value.stat : null
          unit        = can(metric.value.unit) ? metric.value.unit : null
          dimensions  = can(metric.value.dimensions) ? metric.value.dimensions : {}
        }
      }

    }
  }

  alarm_actions             = "${var.alarm_actions}"
  ok_actions                = "${var.ok_actions}"

  dimensions = var.use_metric_query ? null : {
    "${var.dimensions_name}" = var.dimensions_value
  }
}

