data "terraform_remote_state" "ndelius" {
  backend = "s3"
  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/application/ndelius/terraform.tfstate"
    region = "${var.region}"
  }
}
