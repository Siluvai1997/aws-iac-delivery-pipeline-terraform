# Build AWS CodeCommit git repo
resource "aws_codecommit_repository" "repo" {
  repository_name = var.repository_name
  description     = "CodeCommit repo for Java Quarkus Project"
}