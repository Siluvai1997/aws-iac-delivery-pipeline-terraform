
# Create CodeBuild Project for Java
resource "aws_codebuild_project" "codebuild_project_java_build" {
  name          = var.codebuild_project_java_build_name
  description   = "Java codebuild project"
  build_timeout = "5"
  service_role  = var.codebuild_iam_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = var.s3_logging_bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${var.s3_logging_bucket_id}/${var.codebuild_project_java_build_name}/build-log"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

    vpc_config {
    vpc_id = "vpc-0853f07c56d69c3fc"
    subnets = ["subnet-0e499c24278b14da1"]
    security_group_ids = ["sg-03d8aa6b1ab37d768"]
  }

  tags = {
    Terraform = "true"
  }
}