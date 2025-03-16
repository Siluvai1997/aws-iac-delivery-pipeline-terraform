##
# Define variables for Bootstrap module
##
variable "project_iam_group_name" {
  description = "Name for IAM Group utilized by Project team"
}
variable "project_iam_group_policy_name" {
  description = "Name for IAM policy used by Project team"
}
variable "java_codecommit_repo_arn" {
  description = "Code Commit Repo ARN for JavaProject1"
}
variable "codebuild_java_build_arn" {
  description = "CodeBuild Project ARN"
}
variable "codepipeline_java_arn" {
  description = "CodePipeline Project ARN"
}
