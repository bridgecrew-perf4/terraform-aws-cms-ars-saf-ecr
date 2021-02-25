locals {
  # Use our standard lifecycle policy if none passed in.
  policy = var.lifecycle_policy == "" ? file("${path.module}/lifecycle-policy.json") : var.lifecycle_policy
  # Use githubactions as default ci runner name
  ci_name = var.ci == "" ? "GithubActions" : var.ci

  tags = {
    Automation = "Terraform"
  }
}

resource "aws_ecr_repository" "main" {
  name = var.container_name
  tags = merge(local.tags, var.tags)
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name
  policy     = local.policy
}

# Only create the resource if policy is specified. By Default AWS does not
# attach a ECR policy to a repository.
resource "aws_ecr_repository_policy" "main" {
  repository = aws_ecr_repository.main.name
  policy     = var.ecr_policy
  count      = length(var.ecr_policy) > 0 ? 1 : 0
}

# aws IAM user for github actions CI
resource "aws_iam_user" "main" {
  name          = "${lower(local.ci_name)}-${aws_ecr_repository.main.name}"
  force_destroy = true

  tags = {
    Automation = "Terraform"
  }
}

resource "aws_iam_group" "main" {
  name = "${lower(local.ci_name)}-${aws_ecr_repository.main.name}"
}

resource "aws_iam_group_membership" "main" {
  name  = "${lower(local.ci_name)}-${aws_ecr_repository.main.name}-group-membership"
  users = ["${lower(local.ci_name)}-${aws_ecr_repository.main.name}"]
  group = aws_iam_group.main.name
}

data "aws_iam_policy_document" "main" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
    ]

    resources = [
      aws_ecr_repository.main.arn,
    ]
  }
}

resource "aws_iam_policy" "main" {
  name        = "${lower(local.ci_name)}-ecr-${aws_ecr_repository.main.name}-policy"
  description = "Allow ${local.ci_name} to push new ${aws_ecr_repository.main.name} ECR images"
  path        = "/"
  policy      = data.aws_iam_policy_document.main.json
}

resource "aws_iam_group_policy_attachment" "main" {
  group      = aws_iam_group.main.name
  policy_arn = aws_iam_policy.main.arn
}