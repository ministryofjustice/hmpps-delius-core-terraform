# National Delius UMT - User Management Tool

[UMT](https://github.com/ministryofjustice/ndelius-um) is used to manage users in the Delius application.

This module defines a load-balanced ECS cluster running a docker image from ECR, which is configured to manage the delius-core LDAP.

## Resources
* `ecs.tf` - ECS cluster, service and task definition
* `asg.tf` - Launch configuration and auto-scaling group
* `iam.tf` - IAM role and instance profile attached to the EC2 instances
* `alb.tf` - Internal application load balancer and target group
* `nlb.tf` - External network load balancer to sit in front of the ALB
* `dns.tf` - Route53 DNS entries for the load balancer
