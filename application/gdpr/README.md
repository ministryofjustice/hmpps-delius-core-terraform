# National Delius GDPR Compliance Tool

The Delius GDPR (General Data Protection Regulation) service provides an API, a User Interface, and a suite of Batch processes to support the retention and deletion of data within the National Delius estate. 

This module defines two ECS services running on the shared Delius ECS cluster: one for the API and Batch processes and another for the User Interface.
It also defines an RDS Postgresql database used for storing retention and deletion data, as well as configuration and internal batch processing infomation.

## Resources
* `api-service.tf` - ECS service, task definition, scaling policies and service registry entry for the Back-end (API + Batch)
* `ui-service.tf` - ECS service, task definition, scaling policies and service registry entry for the Front-end (UI)
* `iam.tf` - IAM role and instance profile attached to the EC2 instances
* `rds.tf` - An RDS database instance