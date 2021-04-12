# PDF-Generator

## Context
The [pdf-generator](https://github.com/ministryofjustice/pdf-generator) is used by the New Tech UI to generate PDF documents for Delius users completing one of the new Document Templates (e.g. Short Format Pre-Sentence Report).

## Resources
This module defines an internal ECS service that is accessible from the [New Tech UI service](/application/new-tech-ui) only.

## Configuration
Configured using the `pdf_generator_config` map in the [hmpps-env-configs](https://github.com/ministryofjustice/hmpps-env-configs) repository.
Any properties prefixed with `env_` will be passed to the container as environment variables.
