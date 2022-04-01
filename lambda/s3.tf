resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.region}-${var.short_environment_name}-delius-core-lambda-functions"
  acl    = "private"
  tags   = merge(var.tags, { "Name" = "${var.region}-${var.short_environment_name}-delius-core-lambda-functions" })
  versioning {
    enabled = false
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "lambda_bucket" {
  bucket                  = aws_s3_bucket.lambda_bucket.id
  block_public_acls       = true # Block public access to buckets and objects granted through *new* access control lists (ACLs)
  ignore_public_acls      = true # Block public access to buckets and objects granted through any access control lists (ACLs)
  block_public_policy     = true # Block public access to buckets and objects granted through new public bucket or access point policies
  restrict_public_buckets = true # Block public and cross-account access to buckets and objects through any public bucket or access point policies
}