# Output TF Plan CodeBuild name to main.tf
output "codebuild_java_build_name" {
  value = var.codebuild_project_java_build_name
}
output "codebuild_java_build_arn" {
  value = aws_codebuild_project.codebuild_project_java_build.arn
}
