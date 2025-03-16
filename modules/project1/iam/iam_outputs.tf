# Output the project IAM group and policy to main.tf
output "project_iam_group_arn" {
  value = aws_iam_group.java_developers.arn
}