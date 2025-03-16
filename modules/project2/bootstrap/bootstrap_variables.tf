##
# Define variables for Bootstrap module
##

variable "s3_logging_bucket_name" {
  description = "Name of S3 bucket to use for access logging"
}

variable "codebuild_iam_role_name" {
  description = "Name for IAM Role utilized by CodeBuild"
}
variable "codebuild_iam_role_policy_name" {
  description = "Name for IAM policy used by CodeBuild"
}
variable "java_codecommit_repo_arn" {
  description = "Java CodeCommit git repo ARN"
}
variable "tf_codepipeline_artifact_bucket_arn" {
  description = "Codepipeline artifact bucket ARN"
}
variable "ecr_repo_arn" {
  description = "ECR repo ARN"
}