# National Delius UMT - User Management Tool

[UMT](https://github.com/ministryofjustice/ndelius-um) is used to manage users in the Delius application.

This module defines an ECS service on the shared Delius ECS cluster running a docker image from ECR, which is configured to manage the delius-core LDAP.

## Resources
* `ecs.tf` - ECS service, task definition, scaling policies and service registry entry
* `iam.tf` - IAM role and instance profile attached to the EC2 instances
* `elasticache.tf` - Elasticache Redis replication group, used by UMT for storing OAuth access tokens