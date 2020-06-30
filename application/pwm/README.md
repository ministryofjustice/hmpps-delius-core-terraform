# PWM - Password manager

[PWM](https://github.com/pwm-project/pwm) is an open source password self service application for LDAP directories.

This module defines a load-balanced ECS cluster running the docker image [hmpps/pwm](https://github.com/ministryofjustice/hmpps-pwm),
which is configured to manage the delius-core LDAP.

## Resources
* `ecs.tf` - ECS service
* `alb.tf` - Internal application load balancer for the service
* `nlb.tf` - External network load balancer to sit in front of the ALB, with persistent EIPs
* `dns.tf` - Route53 DNS entries for the external load balancer
