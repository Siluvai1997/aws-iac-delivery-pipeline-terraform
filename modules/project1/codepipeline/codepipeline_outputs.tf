output "tf_codepipeline_artifact_bucket_arn" {
  value = aws_s3_bucket.tf_codepipeline_artifact_bucket.arn
}
output "codepipeline_java_arn" {
  value = aws_codepipeline.tf_codepipeline.arn
}