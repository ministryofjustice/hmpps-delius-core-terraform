# External NLB to forward to internal ALB
resource "aws_lb" "external_nlb" {
  name               = "${var.short_environment_name}-${var.tier_name}-ext"
  internal           = false
  load_balancer_type = "network"
  tags               = "${merge(var.tags, map("Name", "${var.short_environment_name}-${var.tier_name}-ext"))}"
  subnet_mapping {
    subnet_id     = "${var.public_subnets[0]}"
    allocation_id = "${var.eip_allocation_ids[0]}"
  }
  subnet_mapping {
    subnet_id     = "${var.public_subnets[1]}"
    allocation_id = "${var.eip_allocation_ids[1]}"
  }
  subnet_mapping {
    subnet_id     = "${var.public_subnets[2]}"
    allocation_id = "${var.eip_allocation_ids[2]}"
  }
}

resource "aws_lb_target_group" "external_nlb_https_target_group" {
  name      = "${var.short_environment_name}-${substr(var.tier_name, 0, 3)}-nlb-443"
  vpc_id    = "${var.vpc_id}"
  protocol  = "TCP"
  port      = "443"
  tags = "${merge(var.tags, map("Name", "${var.short_environment_name}-${substr(var.tier_name, 0, 3)}-nlb-443"))}"
  health_check {
    protocol  = "TCP"
    port      = "443"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "external_nlb_http_target_group" {
  name      = "${var.short_environment_name}-${substr(var.tier_name, 0, 3)}-nlb-80"
  vpc_id    = "${var.vpc_id}"
  protocol  = "TCP"
  port      = "80"
  tags = "${merge(var.tags, map("Name", "${var.short_environment_name}-${substr(var.tier_name, 0, 3)}-nlb-80"))}"
  health_check {
    protocol  = "TCP"
    port      = "80"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "external_nlb_https_listener" {
  load_balancer_arn = "${aws_lb.external_nlb.arn}"
  port              = "443"
  protocol          = "TCP"
  default_action {
    target_group_arn = "${aws_lb_target_group.external_nlb_https_target_group.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "external_nlb_http_listener" {
  load_balancer_arn = "${aws_lb.external_nlb.arn}"
  port              = "80"
  protocol          = "TCP"
  default_action {
    target_group_arn = "${aws_lb_target_group.external_nlb_http_target_group.arn}"
    type             = "forward"
  }
}
