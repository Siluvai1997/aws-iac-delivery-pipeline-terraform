
# Define variables for AWS CodePipeline

variable "tf_codepipeline_artifact_bucket_name" {
  description = "Name of the Java CodePipeline S3 bucket for artifacts"
}
variable "tf_codepipeline_role_name" {
  description = "Name of the Java CodePipeline IAM Role"
}
variable "tf_codepipeline_role_policy_name" {
  description = "Name of the Java IAM Role Policy"
}
variable "tf_codepipeline_name" {
  description = "Java CodePipeline Name"
}
variable "java_codecommit_repo_name" {
  description = "Java CodeCommit repo name"
}
variable "codebuild_java_build_name" {
  description = "Java codebuild project name"
}
