resource "aws_security_group" "pingdom_in" {
  name        = "${var.environment_name}-pingdom-in"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Pingdom probe servers ingress"
  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_name}-pingdom_in"
      "Type" = "Private"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_pingdom_in_id" {
  value = aws_security_group.pingdom_in.id
}

## Note: Security group rules will be filled in by a Lambda which will poll api.pingdom.com/api/2.1/probes
