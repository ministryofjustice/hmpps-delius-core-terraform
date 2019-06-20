# S3 Buckets
output "alb_ips_bucket_name" {
  value = "${module.alb-ips-bucket.s3_bucket_name}"
}

output "alb_ips_bucket_arn" {
  value = "${module.alb-ips-bucket.s3_bucket_arn}"
}

output "s3_alb_ips" {
  value = {
      arn    = "${module.alb-ips-bucket.s3_bucket_arn}",
      domain = "${module.alb-ips-bucket.bucket_domain_name}",
      name   = "${module.alb-ips-bucket.s3_bucket_name}",
      region = "${var.region}"
    }
}
