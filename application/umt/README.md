# National Delius UMT - User Management Tool

[UMT](https://github.com/ministryofjustice/ndelius-um) is used to manage users in the Delius application.

This module defines an ECS cluster running a docker image from ECR, which is configured to manage the delius-core LDAP.

## Resources
* `ecs.tf` - ECS cluster, service and task definition
* `asg.tf` - Launch configuration and auto-scaling group
* `iam.tf` - IAM role and instance profile attached to the EC2 instances