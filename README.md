### End-to-end automation of infrastructure deployment on AWS using Terraform and a CI/CD pipeline built with CodeCommit, CodeBuild, and CodePipeline.
This project sets up a complete Infrastructure as Code (IaC) delivery pipeline using AWS native services (CodeCommit, CodeBuild, CodePipeline) to automate Terraform-based deployments to AWS environments.

#### Steps
- scripts will create the resources (such as IAM roles and policies, CodeCommit Repo, CodeBuild projects, CodePipeline, S3 buckets and DynamoDB) required for the pipeline.
- configure to use the S3 backend and dynamodb to maintain the state file.
- clone the CodeCommit repo and push the code from local environment to Codecommit repo master branch. Any subsequent changes on the code, will trigger the pipeline and provision the resources on the pipeline.

#### Notes
- AWS Resources grouped into various modules and placed them under modules/ folder.  
- config.tf contains the terraform configuration and aws provider plugin information.
- main.tf is the file to register the child modules. 
- This project contains the three different buildspec YAML files to run the CodeBuild.

Terraform script version used in this project: 0.12.26
Reference: https://www.terraform.io/
