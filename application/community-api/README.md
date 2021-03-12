# Community-API

## Context
The [community-api](https://github.com/ministryofjustice/community-api) provides access to Probation data relating to Service Users in the community.

## Resources
This Terraform module defines a load-balanced ECS service, running the community-api Docker container.

## Configuration
Configured using the `community_api_config` map in the [hmpps-env-configs](https://github.com/ministryofjustice/hmpps-env-configs) repository.
Any keys prefixed with `env_` or `secret_` will be passed to the container as environment variables.

## Security
Security Groups grant inbound access to the load balancer from known sources only.
! TODO add more details here

See [security-groups/community-api.tf](/security-groups/community-api.tf).

