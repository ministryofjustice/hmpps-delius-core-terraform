resource "aws_s3_bucket" "config_bucket" {
  bucket = "${local.bucket_name}"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = "${merge(var.tags, map("Name", "${local.bucket_name}"))}"
}

resource "aws_s3_bucket_object" "pwm_war_object" {
  key     = "pwm-${local.pwm_config["version"]}.war"
  source  = "files/pwm-${local.pwm_config["version"]}.war"
  bucket  = "${aws_s3_bucket.config_bucket.id}"
}

resource "aws_s3_bucket_object" "pwm_config_object" {
  key     = "PwmConfiguration.xml"
  content = "${data.template_file.pwm_configuration.rendered}"
  bucket  = "${aws_s3_bucket.config_bucket.id}"
}