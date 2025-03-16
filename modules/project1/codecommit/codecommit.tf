# Build AWS CodeCommit git repo
resource "aws_codecommit_repository" "repo" {
  repository_name = var.repository_name
  description     = "CodeCommit repo for Java Project"
}

# Create CodeCommit notification rule
resource "aws_codestarnotifications_notification_rule" "commits" {
  detail_type    = "FULL"
  event_type_ids = ["codecommit-repository-comments-on-commits","codecommit-repository-pull-request-created","codecommit-repository-branches-and-tags-updated"]

  name     = "Java-codecommit-repo-notification"
  resource = aws_codecommit_repository.repo.arn

  target {
    address = var.sns_topic_arn
  }
}

# Data source for SNS Topic policy
data "aws_iam_policy_document" "codecommit_notif_access" {
  statement {
    actions = ["sns:Publish"]

    principals {
      type        = "Service"
      identifiers = ["codestar-notifications.amazonaws.com"]
    }

    resources = [var.sns_topic_arn]
  }
}

# Updating SNS topic default policy
resource "aws_sns_topic_policy" "default" {
  arn    = var.sns_topic_arn
  policy = data.aws_iam_policy_document.codecommit_notif_access.json
}