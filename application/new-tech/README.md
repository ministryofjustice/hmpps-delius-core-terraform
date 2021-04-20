# New-Tech UI

## Context
The [ndelius-new-tech](https://github.com/ministryofjustice/ndelius-new-tech) application is a front-end for various services that are integrated into National Delius.
For example, the [probation offender search service](https://github.com/ministryofjustice/probation-offender-search) and the [pdf-generator](https://github.com/ministryofjustice/pdf-generator) document workflows (eg. Short Format Pre-Sentence Report).

## Resources
This module defines an internal ECS service that is accessible from the National Delius front-end load balancer, on the path `/newTech`.

## Configuration
Configured using the `new_tech_config` map in the [hmpps-env-configs](https://github.com/ministryofjustice/hmpps-env-configs) repository.
Any keys prefixed with `env_` or `secret_` will be passed to the container as environment variables.

Any environment variables that should be pulled from Terraform data (e.g. remote state, vpc details) are defined in [ecs.tf#environment](ecs.tf).
