resource "aws_cloudwatch_composite_alarm" "foobar" {
  alarm_name                = var.alarm_name

  alarm_rule                 = var.composite_alarm_rule

  alarm_actions             = "${var.alarm_actions}"
  ok_actions                = "${var.ok_actions}"
}
