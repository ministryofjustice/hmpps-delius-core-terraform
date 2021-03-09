# Delius-API

## Context
The [delius-api](https://github.com/ministryofjustice/hmpps-delius-api) provides granular access to data held within the National Delius application, enabling updates to be performed by other Digital services in a safe and controlled manner.  

## Resources
This Terraform module defines a load-balanced ECS service running the public docker image [hmpps/delius-api](https://gallery.ecr.aws/hmpps/delius-api),
which is configured with access to the Delius database.

## Configuration
Configure the service using the `delius_api_config` map in the [hmpps-env-configs](https://github.com/ministryofjustice/hmpps-env-configs) repository.
Additionally, `delius_api_environment` and `delius_api_secrets` define the environment variables that are passed to the Delius-API containers.

## Security
Security Groups grant inbound access to the load balancer from known internal sources only. 
This includes access from the private subnets (via NAT Gateway), the SSH Bastion, and the MOJ and Digital Studio VPNs.

See [security-groups/delius-api.tf](/security-groups/delius-api.tf).

