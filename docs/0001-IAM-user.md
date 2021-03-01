# Create Iam user to push container images into ECR repo

In order for github actions to push new container images into the ECR repo we need an Iam user. This Iam user will have write permissions to the ECR repo created as part of terraform module. 

Date: 2021-03-01

Author: @rdhariwal

## Manual Work Performed

* apply terraform module and get the arn for the ECR repo created by the module
* file a ticket with [CMS Cloud Support team](https://jiraent.cms.gov/plugins/servlet/desk/portal/22) to create an Iam user with the following policy.
    * update the Resource arn with your ECR repo'a arn

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "ecr:GetAuthorizationToken",
            "Resource": "*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "ecr:UploadLayerPart",
                "ecr:PutImage",
                "ecr:ListImages",
                "ecr:InitiateLayerUpload",
                "ecr:GetRepositoryPolicy",
                "ecr:GetDownloadUrlForLayer",
                "ecr:DescribeRepositories",
                "ecr:DescribeImages",
                "ecr:CompleteLayerUpload",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability"
            ],
            "Resource": "arn:aws:ecr:::repository"
        }
    ]
}

```

## AWS Accounts

* [ ] aws-cms-oit-iusg-spe-cmcs-macbis-dev

## Reason for Manual Execution

Because CMS limits creation of Iam users we need a workaround to create an Iam user that will have permission to push to ECR repo.