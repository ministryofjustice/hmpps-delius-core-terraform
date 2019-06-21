# PWM - Password manager

[PWM](https://github.com/pwm-project/pwm) is an open source password self service application for LDAP directories.

This module defines a load-balanced ECS cluster running the docker image [fjudith/pwm](https://hub.docker.com/r/fjudith/pwm), which is configured to manage the delius-core LDAP.

The docker image runs an instance of the PWM application on Tomcat 8.

## Resources
* `ecs.tf` - ECS cluster, service and task definition
* `asg.tf` - Launch configuration and auto-scaling group
* `iam.tf` - IAM role and instance profile attached to the EC2 instances
* `alb.tf` - Internal application load balancer and target group
* `nlb.tf` - External network load balancer to sit in front of the ALB, with persistent EIPs
* `dns.tf` - Route53 DNS entries for the load balancer
* `ses.tf` - (TODO) SES SMTP service to enable emailing password-reset links

## TODO
* ~~Configure service to talk to delius-core LDAP~~
* ~~LDAP schema changes~~
* Configure email sending
