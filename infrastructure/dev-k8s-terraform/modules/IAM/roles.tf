resource "aws_iam_policy" "policy_for_master_role" {
  name        = "jpolicy_for_master_role"
  policy      = file("./modules/IAM/policy_for_master.json")
}
resource "aws_iam_policy" "policy_for_worker_role" {
  name        = "jpolicy_for_worker_role"
  policy      = file("./modules/IAM/policy_for_worker.json")
}
resource "aws_iam_role" "role_for_master" {
  name = "jrole_master_k8s"
  # Terraform "jsonencode" function converts to a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name = "jrole_for_master"
  }
}
resource "aws_iam_role" "role_for_worker" {
  name = "jrole_worker_k8s"
  # Terraform "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name = "jrole_for_worker"
  }
}
resource "aws_iam_policy_attachment" "attach_for_master" {
  name       = "jattachment_for_master"
  roles      = [aws_iam_role.role_for_master.name]
  policy_arn = aws_iam_policy.policy_for_master_role.arn
}
resource "aws_iam_policy_attachment" "attach_for_worker" {
  name       = "jattachment_for_worker"
  roles      = [aws_iam_role.role_for_worker.name]
  policy_arn = aws_iam_policy.policy_for_worker_role.arn
}
resource "aws_iam_instance_profile" "profile_for_master" {
  name  = "jprofile_for_master"
  role = aws_iam_role.role_for_master.name
}
resource "aws_iam_instance_profile" "profile_for_worker" {
  name  = "jprofile_for_worker"
  role = aws_iam_role.role_for_worker.name
}
output master_profile_name {
  value       = aws_iam_instance_profile.profile_for_master.name
}
output worker_profile_name {
  value       = aws_iam_instance_profile.profile_for_worker.name
}