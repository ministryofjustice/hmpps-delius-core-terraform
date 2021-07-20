# WebLogic

Defines a load-balanced ECS service, running the NDelius application on WebLogic 14c.

## Resources
* `ecs.tf` - Module defining the ECS service.
* `alb.tf` - External application load-balancer.
* `dns.tf` - External and internal Route53 records.
* `lambda.tf` - Scheduled function to trigger a nightly restart.
