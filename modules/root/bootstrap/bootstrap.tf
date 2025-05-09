##
# Module to build resources in AWS
##

# Build an S3 bucket to store TF state
resource "aws_s3_bucket" "state_bucket" {
  bucket = var.s3_tfstate_bucket

  # Tells AWS to encrypt the S3 bucket at rest by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # Tells AWS to keep a version history of the state file
  versioning {
    enabled = true
  }

  tags = {
    Terraform = "true"
  }
}


# Build a DynamoDB to use for terraform state locking
resource "aws_dynamodb_table" "tf_lock_state" {
  name = var.dynamo_db_table_name

  # Pay per request is cheaper for low-i/o applications, like our TF lock state
  billing_mode = "PAY_PER_REQUEST"

  # Hash key is required, and must be an attribute
  hash_key = "LockID"

  # Attribute LockID is required for TF to use this table for lock state
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name      = var.dynamo_db_table_name
    Terraform = "true"
  }
}


# Build an AWS S3 bucket for logging
resource "aws_s3_bucket" "s3_logging_bucket" {
  bucket = var.s3_logging_bucket_name
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}


# Create an IAM role for CodeBuild to assume
resource "aws_iam_role" "codebuild_iam_role" {
  name = var.codebuild_iam_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


# Create an IAM role policy for CodeBuild to use implicitly
resource "aws_iam_role_policy" "codebuild_iam_role_policy" {
  name = var.codebuild_iam_role_policy_name
  role = aws_iam_role.codebuild_iam_role.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "codebuild:CreateReportGroup",
        "codebuild:CreateReport",
        "codebuild:UpdateReport",
        "codebuild:BatchPutTestCases",
        "codebuild:*",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs",
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface"
      ]
    },

    {
     "Effect": "Allow",
      "Action": [
                "ec2:CreateNetworkInterfacePermission"
            ],
       "Resource": "arn:aws:ec2:ca-central-1:495637283141:network-interface/*",
        "Condition": {
                "StringEquals": {
                    "ec2:Subnet": [
                        "arn:aws:ec2:ca-central-1:495637283141:subnet/subnet-0e499c24278b14da1"
                    ],
                    "ec2:AuthorizedService": "codebuild.amazonaws.com"
                }
            }
        },

    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.s3_logging_bucket.arn}",
        "${aws_s3_bucket.s3_logging_bucket.arn}/*",
        "${aws_s3_bucket.state_bucket.arn}",
        "${aws_s3_bucket.state_bucket.arn}/*",
        "${var.tf_codepipeline_artifact_bucket_arn}",
        "${var.tf_codepipeline_artifact_bucket_arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:*"
      ],
      "Resource": "${aws_dynamodb_table.tf_lock_state.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codecommit:BatchGet*",
        "codecommit:BatchDescribe*",
        "codecommit:Describe*",
        "codecommit:EvaluatePullRequestApprovalRules",
        "codecommit:Get*",
        "codecommit:List*",
        "codecommit:GitPull",
        "codecommit:PostCommentForPullRequest",
        "codecommit:UpdatePullRequestApprovalState"
      ],
      "Resource": [
            "${var.terraform_codecommit_repo_arn}"
           ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:Get*",
        "iam:List*"
      ],
      "Resource": "${aws_iam_role.codebuild_iam_role.arn}"
    },
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "${aws_iam_role.codebuild_iam_role.arn}"
    }
  ]
}
POLICY
}


# Create IAM role for Terraform builder to assume
resource "aws_iam_role" "tf_iam_assumed_role" {
  name = "TfRootAssumeIamRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.codebuild_iam_role.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    Terraform = "true"
  }
}


# Create broad IAM policy Terraform to use to build, modify resources
resource "aws_iam_policy" "tf_iam_assumed_policy" {
  name = "TfRootAssumeIamPolicy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAllPermissions",
      "Effect": "Allow",
      "Action": [
        "*"
      ],
      "Resource": "*"
    },
    {
         "Sid":"AllowRDSDescribe",
         "Effect":"Allow",
         "Action":"rds:Describe*",
         "Resource":"*"
      }
  ]
}
EOF
}

# Attach IAM assume role to policy
resource "aws_iam_role_policy_attachment" "tf_iam_attach_assumed_role_to_permissions_policy" {
  role       = aws_iam_role.tf_iam_assumed_role.name
  policy_arn = aws_iam_policy.tf_iam_assumed_policy.arn
}

resource "aws_iam_role_policy_attachment" "rds_full" {
  role        = aws_iam_role.tf_iam_assumed_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_full" {
  role        = aws_iam_role.tf_iam_assumed_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}