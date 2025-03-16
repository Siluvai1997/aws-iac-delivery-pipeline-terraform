# Build AWS ECR repo
resource "aws_ecr_repository" "container_repo" {
  name                 = var.name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}