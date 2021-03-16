# National Delius Approved Premises Tracker API

> :memo: This API has not been enabled in Production Delius environments. To enable it, increase the `default_aptracker_api_config` min/max capacity in [hmpps-env-configs](https://github.com/ministryofjustice/hmpps-env-configs/blob/master/common-prod/common.tfvars).

The Approved Premises Tracker API is used by the external Approved Premises Tracker to view and manage details of Approved Premises within Delius.

This module defines an ECS service on the shared Delius ECS cluster running a docker image from ECR, which is configured to talk to the Delius database.

## Resources
* `ecs.tf` - ECS service, task definition, scaling policies and service registry entry
* `iam.tf` - IAM role and instance profile attached to the EC2 instances