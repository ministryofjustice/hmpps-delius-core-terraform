# hmpps-delius-core-terraform
Infrastructure and provisioning of Delius Core environments

### Purpose
This repo contains terraform code to create Delius Core testing environments.

### Structure
The repo contains top level directories,
each of which (except for the env_configs directory) corresponds to an architectural component.
These directories contain a single terraform configuration, allowing the components to be created separately, subject to the dependencies between them.

The configurations are decoupled from each other by the use of terraform data blocks bringing in name/tag values from the other components.
You should not be referencing IDs or other data directly emitted as outputs from other components.

Each configuration constructs any local identifiers from a short list of variables (region, project, environment type, vpc CIDR, account ID) passed in.
You should not leak derived values into the env_configs directory (see below)

There is also a env_config directory, which contains configuration specific to each environment.
Each environment has a pair of files - a <env_type>.properties.sh file which sets up environment variables identifying the environment, and a <dev_name>.tfvars file which contains environment-specific variables.

The configurations are run with terragrunt, and all terragrunt related code should remain in the env_configs file and 2 files in the top-level folder of each configuration (main.tf, terraform.tfvars).
You should not leak terragrunt related code into other files or modules within the configuration.

### Usage

To run a single configuration locally, with terragrunt installed:

1. Run one of the <env_type>.properties.sh files, to select which environment you are working with.
2. Navigate to the directory corresponding to the component you want to update
3. terragrunt init
4. terragrunt plan
5. terragrunt apply

It is also possible to run all configurations with the terragrunt *-all commands, from the top-level directory.

It is recommended to use the containerised teraform/terragrunt tooling, to ensure consistency with the automated CI build.

It is even more recommended to use the automated CI build directly.
