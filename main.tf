
## Module to build the resources required for terraform to run CI/CD environment
module "bootstrap" {
  source                              = "./modules/root/bootstrap"
  s3_tfstate_bucket                   = "codebuild-root-tf-tfstate"
  s3_logging_bucket_name              = "codebuild-root-logging-bucket"
  dynamo_db_table_name                = "codebuild-db-root-tf-locking"
  codebuild_iam_role_name             = "CodeBuildTfRootIamRole"
  codebuild_iam_role_policy_name      = "CodeBuildTfRootIamRolePolicy"
  terraform_codecommit_repo_arn       = module.codecommit.terraform_codecommit_repo_arn
  tf_codepipeline_artifact_bucket_arn = module.codepipeline.tf_codepipeline_artifact_bucket_arn
}

## Module to Build a SNS topic and subscription
module "sns" {
  source          = "./modules/root/sns"
  display_name    = "Terraform Admin Project Notify"
  email_addresses = ["siluvai.antony@gmail.com"]
  stack_name      = "root-codecommit-sns-stack"
}

#Module to deploy Sonarqube on AWS ECS Fargate
module "sonarqube" {
  source  = "./modules/root/sonarqube"
}

#Module to deploy Sonatype Nexus3 on AWS ECS Fargate
module "nexus" {
  source  = "./modules/root/nexus"
}

## Module to Build a CodeCommit git repo
module "codecommit" {
  source          = "./modules/root/codecommit"
  repository_name = "CodeCommitTerraformRoot"
  sns_topic_arn   = module.sns.sns_topic_arn
}


## Build CodeBuild projects for Terraform Plan and Terraform Apply
module "codebuild" {
  source                                 = "./modules/root/codebuild"
  codebuild_project_terraform_validation_name = "RootTerraformValidation"
  codebuild_project_terraform_plan_name  = "RootTerraformPlan"
  codebuild_project_terraform_apply_name = "RootTerraformApply"
  s3_logging_bucket_id                   = module.bootstrap.s3_logging_bucket_id
  codebuild_iam_role_arn                 = module.bootstrap.codebuild_iam_role_arn
  s3_logging_bucket                      = module.bootstrap.s3_logging_bucket
  sns_topic_arn                          = module.sns.sns_topic_arn
}


## Build a CodePipeline for Terraform 
module "codepipeline" {
  source                               = "./modules/root/codepipeline"
  tf_codepipeline_name                 = "RootTfCodePipeline"
  tf_codepipeline_artifact_bucket_name = "root-codebuild-artifact-bucket-name"
  tf_codepipeline_role_name            = "RootTfCodePipelineIamRole"
  tf_codepipeline_role_policy_name     = "RootTfCodePipelineIamRolePolicy"
  terraform_codecommit_repo_name       = module.codecommit.terraform_codecommit_repo_name
  codebuild_terraform_validation_name  = module.codebuild.codebuild_terraform_validation_name
  codebuild_terraform_plan_name        = module.codebuild.codebuild_terraform_plan_name
  codebuild_terraform_apply_name       = module.codebuild.codebuild_terraform_apply_name
  sns_topic_arn                        = module.sns.sns_topic_arn
}


#### Copy and paste the below TF configuration Project 1 template for project 2, 3 and etc and changed the variable names to avoid duplicate issues.

### TF Configuration for Project1

## Build an S3 bucket and IAM Roles and policies for CodeBuild
module "bootstrap_project1" {
  source                              = "./modules/project1/bootstrap"
  s3_logging_bucket_name              = "codebuild-project-logging-bucket1"
  codebuild_iam_role_name             = "CodeBuildProjectIamRole1"
  codebuild_iam_role_policy_name      = "CodeBuildProjectIamRolePolicy1"
  java_codecommit_repo_arn            = module.codecommit_project1.java_codecommit_repo_arn
  tf_codepipeline_artifact_bucket_arn = module.codepipeline_project1.tf_codepipeline_artifact_bucket_arn
}

## Module to Build a SNS topic and subscription
module "sns_project1" {
  source          = "./modules/project1/sns"
  display_name    = "Java Project Notify"
  email_addresses = ["siluvai.antony@gmail.com"]
  stack_name      = "javaproject-codecommit-sns-stack"
}

## Build a CodeCommit git repo for Java Project 1
module "codecommit_project1" {
  source          = "./modules/project1/codecommit"
  repository_name = "CodeCommitJavaProject1"
  sns_topic_arn   = module.sns_project1.sns_topic_arn
}

## CodeBuild project for Java Project1
module "codebuild_project1" {
  source                                  = "./modules/project1/codebuild"
  codebuild_project_java_build_name       = "JavaBuildProject1"
  s3_logging_bucket_id                    = module.bootstrap_project1.s3_logging_bucket_id
  codebuild_iam_role_arn                  = module.bootstrap_project1.codebuild_iam_role_arn
  s3_logging_bucket                       = module.bootstrap_project1.s3_logging_bucket
}

## Build a CodePipeline for Java Project 1 
module "codepipeline_project1" {
  source                               = "./modules/project1/codepipeline"
  tf_codepipeline_name                 = "JavaCodePipeline1"
  tf_codepipeline_artifact_bucket_name = "javap-codebuild-artifact-bucket"
  tf_codepipeline_role_name            = "JavaCodePipelineIamRole"
  tf_codepipeline_role_policy_name     = "JavaCodePipelineIamRolePolicy"
  java_codecommit_repo_name            = module.codecommit_project1.java_codecommit_repo_name
  codebuild_java_build_name            = module.codebuild_project1.codebuild_java_build_name
}

## Build IAM groups and policies for Project team
module "iam_project1" {
   source                             = "./modules/project1/iam"
   project_iam_group_name             = "DevelopersGrp1"
   project_iam_group_policy_name      = "DevelopersCustomPolicy1"
   java_codecommit_repo_arn           = module.codecommit_project1.java_codecommit_repo_arn
   codebuild_java_build_arn           = module.codebuild_project1.codebuild_java_build_arn 
   codepipeline_java_arn              = module.codepipeline_project1.codepipeline_java_arn 
 }

#### Start with Terraform modules for Project 2

## Build a S3 bucket and IAM Roles and policies for CodeBuild
module "bootstrap_project2" {
  source                              = "./modules/project2/bootstrap"
  s3_logging_bucket_name              = "codebuild-project-logging-bucket2"
  codebuild_iam_role_name             = "CodeBuildProjectIamRole2"
  codebuild_iam_role_policy_name      = "CodeBuildProjectIamRolePolicy2"
  java_codecommit_repo_arn            = module.codecommit_project2.java_codecommit_repo_arn
  tf_codepipeline_artifact_bucket_arn = module.codepipeline_project2.tf_codepipeline_artifact_bucket_arn
  ecr_repo_arn                        = module.ecr_project2.ecr_repo_arn
}


## Build a CodeCommit git repo for Java Project 2
module "codecommit_project2" {
  source          = "./modules/project2/codecommit"
  repository_name = "CodeCommitJavaProject2"
}

## CodeBuild project for Java Project2
module "codebuild_project2" {
  source                                  = "./modules/project2/codebuild"
  codebuild_project_java_build_name       = "JavaBuildProject2"
  codebuild_project_code_quality_name     = "JavaQualityProject2"
  s3_logging_bucket_id                    = module.bootstrap_project2.s3_logging_bucket_id
  codebuild_iam_role_arn                  = module.bootstrap_project2.codebuild_iam_role_arn
  s3_logging_bucket                       = module.bootstrap_project2.s3_logging_bucket
}

## Build a ECR repo for Java Project 2
module "ecr_project2" {
  source          = "./modules/project2/ecr"
  name            = "javaquarkusdocker"
}


## Build a CodePipeline for Java Project 2
module "codepipeline_project2" {
  source                               = "./modules/project2/codepipeline"
  tf_codepipeline_name                 = "JavaCodePipeline2"
  tf_codepipeline_artifact_bucket_name = "javap-codebuild-artifact-bucket2"
  tf_codepipeline_role_name            = "JavaCodePipelineIamRole2"
  tf_codepipeline_role_policy_name     = "JavaCodePipelineIamRolePolicy2"
  java_codecommit_repo_name            = module.codecommit_project2.java_codecommit_repo_name
  codebuild_java_build_name            = module.codebuild_project2.codebuild_java_build_name
  codebuild_code_quality_name          = module.codebuild_project2.codebuild_code_quality_name
  tf_cloudformation_role_name          = "TfCloudFormationTrustRole"
  tf_cloudformatiom_role_policy_name   = "TfCloudFormatiomTrustRolePolicy"
}



