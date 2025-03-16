##
# Module to build resources in AWS
##
# Create an IAM group for the project team
resource "aws_iam_group" "java_developers" {
  name = var.project_iam_group_name
}

# Create a custom defined policy for the project team to access AWS resources
resource "aws_iam_group_policy" "java_developer_policy" {
  name  = var.project_iam_group_policy_name
  group = aws_iam_group.java_developers.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
     {
      "Sid":"CodeCommitReadAccess",
      "Effect": "Allow",
      "Action": [
        "codecommit:EvaluatePullRequestApprovalRules",
        "codecommit:Merge*",
        "codecommit:TagResource",
        "codecommit:BatchGetPullRequests",
        "codecommit:CreateBranch",
        "codecommit:CreatePullRequest",
        "codecommit:DescribePullRequestEvents",
        "codecommit:GetBranch",
        "codecommit:GetComment",
        "codecommit:GetCommentsForComparedCommit",
        "codecommit:GetCommentsForPullRequest",
        "codecommit:GetCommit",
        "codecommit:GetCommitHistory",
        "codecommit:GetCommitsFromMergeBase",
        "codecommit:GetDifferences",
        "codecommit:GetMergeConflicts",
        "codecommit:GetObjectIdentifier",
        "codecommit:GetPullRequest",
        "codecommit:GetReferences",
        "codecommit:GetRepository",
        "codecommit:GetRepositoryTriggers",
        "codecommit:GetTree",
        "codecommit:GetUploadArchiveStatus",
        "codecommit:GitPull",
        "codecommit:GitPush",
        "codecommit:ListBranches",
        "codecommit:ListPullRequests",
        "codecommit:UpdateComment",
        "codecommit:UpdateDefaultBranch",
        "codecommit:UpdatePullRequestDescription",
        "codecommit:List*",
        "codecommit:Describe*",
        "codecommit:GetBlob"
      ],
      "Resource": [
            "${var.java_codecommit_repo_arn}"
           ]
    },
      {
            "Effect": "Allow",
            "Action": [
                "codecommit:List*"
            ],
            "Resource": "*"
        }, 

        {
            "Sid":"CodeCommitDenyAccess",
            "Effect": "Deny",
            "Action": [
                "codecommit:GitPush",
                "codecommit:DeleteBranch",
                "codecommit:PutFile",
                "codecommit:Merge*"
            ],
             "Resource": [
            "${var.java_codecommit_repo_arn}"
           ],
            "Condition": {
                "StringEqualsIfExists": {
                    "codecommit:References": [
                        "refs/heads/master"   
                    ]
                },
                "Null": {
                    "codecommit:References": false
                }
            }
        },
        { 
             "Sid":"IAMReadOnlyConsoleAccess",
             "Effect":"Allow",
             "Action":[ 
                "iam:ListAccessKeys",
                "iam:ListSSHPublicKeys",
                "iam:ListServiceSpecificCredentials",
                "iam:ListAccessKeys",
                "iam:GetSSHPublicKey"
             ],
            "Resource": [
                 "*"
           ]
          },
        { 
             "Sid":"CodeBuildConsoleAccess",
             "Effect":"Allow",
             "Action":[ 
                "codebuild:StartBuild",
                "codebuild:StopBuild",
                "codebuild:BatchGet*",
                "codebuild:DescribeTestCases",
                "codebuild:List*",
                "codebuild:RetryBuild",
                "codebuild:CreateReportGroup",
                "codebuild:CreateReport",
                "codebuild:UpdateReport",
                "codebuild:BatchPutTestCases",
                "codebuild:DescribeTestCases", 
                "codebuild:ListReportGroups", 
                "codebuild:ListReports", 
                "codebuild:ListReportsForReportGroup" 
             ],
            "Resource": [
                 "${var.codebuild_java_build_arn}"
           ]
          },
          {
            "Effect": "Allow",
            "Action": [
                "codebuild:List*"
            ],
            "Resource": "*"
        },
          { 
             "Sid":"CodePipelineReadAccess",
             "Effect":"Allow",
             "Action":[ 
                "codepipeline:Get*",
                "codepipeline:CreatePipeline",
                "codepipeline:List*",
                "codepipeline:StartPipelineExecution",
                "codepipeline:StopPipelineExecution",
                "codepipeline:UpdatePipeline"
             ],
            "Resource": [
                 "${var.codepipeline_java_arn}"
           ]
          },
       {
          "Effect": "Allow",
          "Action": [
                "codepipeline:ListPipelines"
            ],
          "Resource": "*"
        },
       {
         "Sid":"S3ReadAccess",
         "Effect": "Allow",
         "Action": [
              "s3:Get*",
              "s3:List*"
            ],
          "Resource": "*"
        },
    {
      "Sid":"CloudformationReadAccess",
      "Effect": "Allow",
      "Action": [
        "cloudformation:CreateStack",
        "cloudformation:DescribeStacks",
        "cloudformation:DescribeChangeSet",
        "cloudformation:SetStackPolicy",
        "cloudformation:ValidateTemplate",
        "cloudformation:List*"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}