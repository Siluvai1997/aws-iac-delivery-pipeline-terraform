Infrastructure Delivery Pipeline using Terraform:
This project directory contains the terraform scripts to create a continuos infrasturcture delivery pipeline using Terraform on AWS. 
At first, the scripts will create the resources (such as IAM roles and policies, CodeCommit Repo, CodeBuild projects, CodePipeline, S3 buckets and DynamoDB) required for the pipeline. The second step is to configure to use the S3 backend and dynamodb to maintain the state file.
Then, we will clone the CodeCommit repo and push the code from local environment to Codecommit repo master branch. Any subsequent changes on the code, will trigger the pipeline and provision the resources on the pipeline.

AWS Resources grouped into various modules and placed them under modules/ folder.  
config.tf contains the terraform configuration and aws provider plugin information.
main.tf is the file to register the child modules. 
This project contains the three different buildspec YAML files to run the CodeBuild.

Terraform script version used in this project: 0.12.26

Reference: https://www.terraform.io/
