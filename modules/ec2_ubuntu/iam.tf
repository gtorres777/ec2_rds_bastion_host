resource "aws_iam_role" "ec2_role_s3_access" {
  name = "ec2_role_s3_access"
  assume_role_policy = file("policies/roles/assume_ec2_role_policy.json")
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "s3_access_policy"
  description = "policy to access all resources on S3"

  policy = file("policies/inline_policies/s3_access.json")
}

resource "aws_iam_role_policy_attachment" "ec2_role_s3_access_policy_attachment" {
  policy_arn = aws_iam_policy.s3_access_policy.arn
  role       = aws_iam_role.ec2_role_s3_access.name
}

resource "aws_iam_instance_profile" "s3-role-instanceprofile" {
 name = "s3-role-instanceprofile-role"
 role = aws_iam_role.ec2_role_s3_access.name
}
