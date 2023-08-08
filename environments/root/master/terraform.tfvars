aws_role_arn="arn:aws:iam::88:role/infrastructure-automation-role"
vpc_id="vpc-aa9"

private_subnets_cidr = <<-EOT
  #!/bin/bash
  aws ssm get-parameter --name "/leadgenius/terraform/root/master/private_subnets_cidr" --with-decryption --query "Parameter.Value" | sed 's/"//g'
EOT

