resource "aws_lb" "nlb" {
  name               = "${var.short_environment_name}-pwm-nlb"
  internal           = false
  load_balancer_type = "network"
  tags               = "${merge(var.tags, map("Name", "${var.short_environment_name}-pwm-nlb"))}"
  subnet_mapping {
    subnet_id     = "${data.terraform_remote_state.vpc.vpc_public-subnet-az1}"
    allocation_id = "${data.terraform_remote_state.persistent-eip.delius_pwm_az1_lb_eip.allocation_id}"
  }
  subnet_mapping {
    subnet_id     = "${data.terraform_remote_state.vpc.vpc_public-subnet-az2}"
    allocation_id = "${data.terraform_remote_state.persistent-eip.delius_pwm_az2_lb_eip.allocation_id}"
  }
  subnet_mapping {
    subnet_id     = "${data.terraform_remote_state.vpc.vpc_public-subnet-az3}"
    allocation_id = "${data.terraform_remote_state.persistent-eip.delius_pwm_az3_lb_eip.allocation_id}"
  }
}

resource "aws_lb_target_group" "https_target_group" {
  name        = "${var.short_environment_name}-pwm-https"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  target_type = "ip"
  protocol    = "TCP"
  port        = "443"
  tags        = "${merge(var.tags, map("Name", "${var.short_environment_name}-pwm-https"))}"
  health_check {
    protocol  = "TCP"
    port      = "443"
  }
}

resource "aws_lb_target_group" "http_target_group" {
  name        = "${var.short_environment_name}-pwm-http"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  target_type = "ip"
  protocol    = "TCP"
  port        = "80"
  tags        = "${merge(var.tags, map("Name", "${var.short_environment_name}-pwm-http"))}"
  health_check {
    protocol  = "TCP"
    port      = "80"
  }
}

module "nlb_to_alb_https" {
  source        = "pbar1/lb-linker/aws"
  version       = "1.0.0"
  name          = "${var.short_environment_name}-pwm-nlb-to-alb-https"
  tags          = "${merge(var.tags, map("Name", "${var.short_environment_name}-pwm-nlb-to-alb-https"))}"
  nlb_tg_arn    = "${aws_lb_target_group.https_target_group.arn}"
  alb_dns_name  = "${aws_lb.alb.dns_name}"
  alb_listener  = "443"
  s3_bucket     = "${data.terraform_remote_state.s3buckets.alb_ips_bucket_name}"
}

module "nlb_to_alb_http" {
  source        = "pbar1/lb-linker/aws"
  version       = "1.0.0"
  name          = "${var.short_environment_name}-pwm-nlb-to-alb-http"
  tags          = "${merge(var.tags, map("Name", "${var.short_environment_name}-pwm-nlb-to-alb-http"))}"
  nlb_tg_arn    = "${aws_lb_target_group.http_target_group.arn}"
  alb_dns_name  = "${aws_lb.alb.dns_name}"
  alb_listener  = "80"
  s3_bucket     = "${data.terraform_remote_state.s3buckets.alb_ips_bucket_name}"
}

resource "aws_lb_listener" "nlb_https_listener" {
  load_balancer_arn = "${aws_lb.nlb.arn}"
  port              = "443"
  protocol          = "TCP"
  default_action {
    target_group_arn = "${aws_lb_target_group.https_target_group.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "external_nlb_http_listener" {
  load_balancer_arn = "${aws_lb.nlb.arn}"
  port              = "80"
  protocol          = "TCP"
  default_action {
    target_group_arn = "${aws_lb_target_group.http_target_group.arn}"
    type             = "forward"
  }
}
