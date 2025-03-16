
# Output the repo info back to main.tf
output "ecr_repo_arn" {
  value = aws_ecr_repository.container_repo.arn
}
output "ecr_repo_name" {
  value = var.name
}
