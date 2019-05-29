# S3 Buckets
output "s3bucket" {
  value = "${module.s3bucket.s3_bucket_name}"
}

output "s3_bucket_arn" {
  value = "${module.s3bucket.s3_bucket_arn}"
}

output "alb_ips_bucket_name" {
  value = "${module.alb-ips-bucket.s3_bucket_name}"
}

output "alb_ips_bucket_arn" {
  value = "${module.alb-ips-bucket.s3_bucket_arn}"
}
