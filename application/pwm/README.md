# PWM - Password manager

[PWM](https://github.com/pwm-project/pwm) is an open source password self service application for LDAP directories.

This module defines a load-balanced ECS cluster running the docker image [fjudith/pwm](https://hub.docker.com/r/fjudith/pwm), which is configured to manage the delius-core LDAP.

The docker image runs an instance of the PWM application on Tomcat 8.

## Resources
* `ecs.tf` - ECS service
* `iam.tf` - IAM policies to allow the ECS container to access configuration in S3
* `alb.tf` - Internal application load balancer for the service
* `nlb.tf` - External network load balancer to sit in front of the ALB, with persistent EIPs
* `dns.tf` - Route53 DNS entries for the load balancer
