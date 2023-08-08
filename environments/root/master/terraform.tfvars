aws_role_arn="arn:aws:iam::88:role/infrastructure-automation-role"
vpc_id="vpc-aa9"

private_subnets_cidr = <<-EOT
  #!/bin/bash
  echo "["11.0.1.0/24", "11.0.2.0/24"]"
EOT
