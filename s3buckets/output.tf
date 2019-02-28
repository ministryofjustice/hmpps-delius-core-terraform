# S3 Buckets
output "s3bucket" {
  value = "${module.s3bucket.s3_bucket_name}"
}

output "s3_bucket_arn" {
  value = "${module.s3bucket.s3_bucket_arn}"
}
