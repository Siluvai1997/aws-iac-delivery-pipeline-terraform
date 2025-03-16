# Output TF Plan CodeBuild name to main.tf
output "codebuild_java_build_name" {
  value = var.codebuild_project_java_build_name
}
output "codebuild_java_build_arn" {
  value = aws_codebuild_project.codebuild_project_java_build.arn
}
# Output Java CodeQuality name to main.tf
output "codebuild_code_quality_name" {
  value = var.codebuild_project_code_quality_name
}
output "codebuild_code_quality_arn" {
  value = aws_codebuild_project.codebuild_project_code_quality.arn
}