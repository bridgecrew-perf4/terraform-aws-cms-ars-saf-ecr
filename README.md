# terraform-aws-cms-ars-saf-ecr

This repo contains a Dockerfile for building a container that can run an
Inspec scan against an AWS account, as well as a Terraform module that
will create an ECR repo to hold the container and the Github Actions that
will publish a new version of the container when the repo is updated.

## Workflow Steps:

1. Initialize the terraform module in your terraform code, so that you have an ECR repo and one AWS IAM account.
1. The AWS IAM account will be used to push new images in ECR repo
1. Generate a new AWS access key and secret in AWS console or from CLI for the IAM account generated in step 1 
1. Add `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` and `AWS_DEFAULT_REGION` to gihub secrets
1. Uncomment the following lines from `workflows/docker-build.yml` so github actions can automatically push new container images into ECR repo
```yaml
#on:
#  push:
#    branches: [main]
```