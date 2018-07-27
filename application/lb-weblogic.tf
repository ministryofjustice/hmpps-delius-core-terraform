resource "aws_lb" "weblogic_lb" {
  internal        = false
  ip_address_type = "ipv4"
  security_groups = [
    "${data.aws_security_group.elb_in.id}",
    "${data.aws_security_group.elb_out.id}",
  ]
  subnets         = ["${data.aws_subnet_ids.public.ids}"]
}

resource "aws_lb_target_group" "weblogic_lb_target_group" {
  port     = 9704
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.vpc.id}"
}

resource "aws_lb_target_group_attachment" "weblogic_lb_target_group_attach" {
  port             = 9704
  target_group_arn = "${aws_lb_target_group.weblogic_lb_target_group.arn}"
  target_id        = "${aws_instance.weblogic.id}"
}

resource "aws_lb_listener" "weblogic-lb-listener" {
  "default_action" {
    target_group_arn = "${aws_lb_target_group.weblogic_lb_target_group.arn}"
    type             = "forward"
  }

  load_balancer_arn = "${aws_lb.weblogic_lb.arn}"
  port              = 9704
}

resource "aws_route53_record" "weblogic_lb" {
  zone_id = "${data.aws_route53_zone.zone.zone_id}"
  name    = "www"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.weblogic_lb.dns_name}"]
}
