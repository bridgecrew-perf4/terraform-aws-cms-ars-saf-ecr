locals {
  # Use our standard lifecycle policy if none passed in.
  policy = var.lifecycle_policy == "" ? file("${path.module}/lifecycle-policy.json") : var.lifecycle_policy

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

# attach a ECR policy to a repository and give read only cross account access to external principal accounts
resource "aws_ecr_repository_policy" "main" {
  repository = aws_ecr_repository.main.name
  policy     = data.aws_iam_policy_document.ecr_read_perms.json
  count      = length(var.allowed_read_principals) > 0 ? 1 : 0
}

data "aws_iam_policy_document" "ecr_read_perms" {

  statement {
    sid = "CrossAccountReadOnly"

    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
    ]

    principals {
      identifiers = var.allowed_read_principals
      type        = "AWS"
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = aws_ecr_repository.main.arn
    }
  }
}