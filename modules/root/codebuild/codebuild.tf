
# Create CodeBuild Project for Terraform Validation
resource "aws_codebuild_project" "codebuild_project_terraform_validation" {
  name          = var.codebuild_project_terraform_validation_name
  description   = "Terraform codebuild project for Validating TF configuration and identify AWS Resource specific issues using Terraform linting"
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
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TERRAFORM_VERSION"
      value = "0.12.26"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${var.s3_logging_bucket_id}/${var.codebuild_project_terraform_validation_name}/build-log"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec_terraform_validation.yml"
  }

  tags = {
    Terraform = "true"
  }
}

# Create CodeBuild Project for Terraform Plan
resource "aws_codebuild_project" "codebuild_project_terraform_plan" {
  name          = var.codebuild_project_terraform_plan_name
  description   = "Terraform codebuild project"
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
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TERRAFORM_VERSION"
      value = "0.12.26"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${var.s3_logging_bucket_id}/${var.codebuild_project_terraform_plan_name}/build-log"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec_terraform_plan.yml"
  }

  tags = {
    Terraform = "true"
  }
}


# Create CodeBuild Project for Terraform Apply
resource "aws_codebuild_project" "codebuild_project_terraform_apply" {
  name          = var.codebuild_project_terraform_apply_name
  description   = "Terraform codebuild project"
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
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TERRAFORM_VERSION"
      value = "0.12.26"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${var.s3_logging_bucket_id}/${var.codebuild_project_terraform_apply_name}/build-log"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec_terraform_apply.yml"
  }

  tags = {
    Terraform = "true"
  }
}

# Create CodeBuild notification rule for terraform validation
resource "aws_codestarnotifications_notification_rule" "builds" {
  detail_type    = "BASIC"
  event_type_ids = ["codebuild-project-build-state-succeeded","codebuild-project-build-state-failed"]

  name     = "Tf-codebuild-notification"
  resource = aws_codebuild_project.codebuild_project_terraform_validation.arn

  target {
    address = var.sns_topic_arn
  }
}

# Create CodeBuild notification rule for terraform plan
resource "aws_codestarnotifications_notification_rule" "builds_plan" {
  detail_type    = "BASIC"
  event_type_ids = ["codebuild-project-build-state-succeeded","codebuild-project-build-state-failed"]

  name     = "Tf-codebuild-plan-notification"
  resource = aws_codebuild_project.codebuild_project_terraform_plan.arn

  target {
    address = var.sns_topic_arn
  }
}

# Create CodeBuild notification rule for terraform plan
resource "aws_codestarnotifications_notification_rule" "builds_apply" {
  detail_type    = "FULL"
  event_type_ids = ["codebuild-project-build-state-succeeded","codebuild-project-build-state-failed"]

  name     = "Tf-codebuild-apply-notification"
  resource = aws_codebuild_project.codebuild_project_terraform_apply.arn

  target {
    address = var.sns_topic_arn
  }
}