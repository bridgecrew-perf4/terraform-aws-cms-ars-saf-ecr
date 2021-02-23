# terraform-aws-cms-ars-saf-ecr

This repo contains a Dockerfile for building a container that can run an
Inspec scan against an AWS account, as well as a Terraform module that
will create an ECR repo to hold the container and the Github Actions that
will publish a new version of the container when the repo is updated.
