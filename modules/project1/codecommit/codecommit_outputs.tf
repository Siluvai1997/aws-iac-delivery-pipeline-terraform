
# Output the repo info back to main.tf
output "java_codecommit_repo_arn" {
  value = aws_codecommit_repository.repo.arn
}
output "java_codecommit_repo_name" {
  value = var.repository_name
}
