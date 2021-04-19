locals {
  bucket_name = "${var.tiny_environment_identifier}-delius-access-logs"
}

resource "aws_s3_bucket" "access_logs" {
  bucket = local.bucket_name
  acl    = "private"
  tags   = merge(var.tags, { "Name" = local.bucket_name })

  versioning {
    enabled = false
  }

  lifecycle_rule {
    id      = "${local.bucket_name}-daily-expiration"
    enabled = true
    expiration { days = 365 }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # ALB access log policy. See https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::652711504416:root" } # eu-west-2
        Action    = "s3:PutObject"
        Resource : "arn:aws:s3:::${local.bucket_name}/*"
      },
      {
        Effect    = "Allow"
        Principal = { Service = "delivery.logs.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "arn:aws:s3:::${local.bucket_name}/*"
        Condition = {
          StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control" }
        }
      },
      {
        Effect    = "Allow"
        Principal = { Service = "delivery.logs.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = "arn:aws:s3:::${local.bucket_name}"
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  bucket                  = aws_s3_bucket.access_logs.id
  block_public_acls       = true # Block public access to buckets and objects granted through *new* access control lists (ACLs)
  ignore_public_acls      = true # Block public access to buckets and objects granted through any access control lists (ACLs)
  block_public_policy     = true # Block public access to buckets and objects granted through new public bucket or access point policies
  restrict_public_buckets = true # Block public and cross-account access to buckets and objects through any public bucket or access point policies
}

