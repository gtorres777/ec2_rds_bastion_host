output "source_code_hash" {
  value = local.source_code_hash
}

output "cloudwatch_canary" {
  value = aws_synthetics_canary.canary
}
