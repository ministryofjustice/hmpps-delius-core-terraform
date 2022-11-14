module "test-project" {
  source                   = "../../modules/ecs_service"
  region                   = var.region
  environment_name         = var.environment_name
  short_environment_name   = var.short_environment_name
  remote_state_bucket_name = var.remote_state_bucket_name
  tags                     = var.tags

  # Application Container
  service_name                   = "test-project"
  health_check_path              = "/health"
  ignore_task_definition_changes = true

  # Security & Networking
  task_role_arn      = aws_iam_role.ecs_sqs_task.arn
  target_group_count = 1
  security_groups = [
    aws_security_group.test-project-instances.id,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_common_out_id,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_delius_db_access_id,
  ]

  # Monitoring
  notification_arn = data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn

  # Scaling
  min_capacity = local.min_capacity
  max_capacity = local.max_capacity
}

resource "aws_iam_role_policy_attachment" "test-project" {
  role       = module.test-project.exec_role.name
  policy_arn = aws_iam_policy.access_ssm_parameters.arn
}

resource "aws_lb" "test-project" {
  internal = false
  subnets = [
    data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az1,
    data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az2,
    data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az3
  ]
  security_groups = [aws_security_group.test-project-lb.id]
  tags            = merge(var.tags, { Name = "${var.short_environment_name}-test-project-lb" })

  access_logs {
    enabled = true
    bucket  = data.terraform_remote_state.access_logs.outputs.bucket_name
    prefix  = "test-project"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "test-project" {
  load_balancer_arn = aws_lb.test-project.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = local.certificate_arn
  default_action {
    type = "forward"
    target_group_arn = module.test-project.primary_target_group["arn"]
  }
}

resource "aws_route53_record" "test-project" {
  zone_id = local.route53_zone_id
  name    = "test-project"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.test-project.dns_name]
}

resource "aws_security_group" "test-project-lb" {
  name        = "${var.environment_name}-test-project-lb"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "test-project load balancer"
  tags        = merge(var.tags, { Name = "${var.environment_name}-test-project-lb" })
  lifecycle {
    create_before_destroy = true
  }
  ingress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = concat(var.internal_moj_access_cidr_blocks, local.bastion_public_ip, local.natgateway_public_ips_cidr_blocks)
    description = "Ingress from VPNs and Bastion hosts"
  }
  ingress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = var.moj_cloud_platform_cidr_blocks
    description = "Ingress from MOJ Cloud Platform"
  }
  egress {
    from_port       = 8080
    protocol        = "tcp"
    to_port         = 8080
    security_groups = [aws_security_group.test-project-instances.id]
    description     = "Egress to instances"
  }
}

resource "aws_security_group" "test-project-instances" {
  name        = "${var.environment_name}-test-project-instances"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "test-project instances"
  tags        = merge(var.tags, { Name = "${var.environment_name}-test-project-instances" })
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "test-project" {
  security_group_id        = aws_security_group.test-project-instances.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = aws_security_group.test-project-lb.id
  description              = "Ingress from load balancer"
}

output "test-project" {
  value = {
    url = "https://${aws_route53_record.test-project.fqdn}"
  }
}
