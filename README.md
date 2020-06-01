# hmpps-delius-core-terraform
Infrastructure and provisioning of Delius Core Applications into Delius environments.
This project has a dependecy on:
https://github.com/ministryofjustice/hmpps-env-configs
https://github.com/ministryofjustice/hmpps-delius-network-terraform


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

## Environment configurations

The environment configurations are to be copied into a directory named `env_configs` with the following example structure:

```
env_configs
├── common
│   ├── common.properties
│   └── common.tfvars
└── delius-core-dev
    ├── delius-core-dev.credentials.yml
    ├── delius-core-dev.properties
    └── delius-core-dev.tfvars
```

An example method of obtaining the configs would be:
```
CONFIG_BRANCH=master
ENVIRONMENT_NAME=delius-core-dev

mkdir -p env_configs/common

wget "https://raw.githubusercontent.com/ministryofjustice/hmpps-env-configs/${CONFIG_BRANCH}/common/common.properties" --output-document="env_configs/common/common.properties"
wget "https://raw.githubusercontent.com/ministryofjustice/hmpps-env-configs/${CONFIG_BRANCH}/common/common.tfvars" --output-document="env_configs/common/common.tfvars"
wget "https://raw.githubusercontent.com/ministryofjustice/hmpps-env-configs/${CONFIG_BRANCH}/${ENVIRONMENT_NAME}/${ENVIRONMENT_NAME}.properties" --output-document="env_configs/${ENVIRONMENT_NAME}/${ENVIRONMENT_NAME}.properties"
wget "https://raw.githubusercontent.com/ministryofjustice/hmpps-env-configs/${CONFIG_BRANCH}/${ENVIRONMENT_NAME}/${ENVIRONMENT_NAME}.tfvars" --output-document="env_configs/${ENVIRONMENT_NAME}/${ENVIRONMENT_NAME}.tfvars"

source env_configs/${ENVIRONMENT_NAME}/${ENVIRONMENT_NAME}.properties
```

or
```
CONFIG_BRANCH=master
TARGET_DIR=env_configs

git clone --depth 1 -b "${CONFIG_BRANCH}" git@github.com:ministryofjustice/hmpps-env-configs.git "${TARGET_DIR}"
```

## Run order

Start with security-groups
then
```
└── security-groups
    └── application
```

The configurations are run with terragrunt, and all terragrunt related code should remain in the env_configs file and 2 files in the top-level folder of each configuration (main.tf, terraform.tfvars).
You should not leak terragrunt related code into other files or modules within the configuration.

### Usage

To run a single configuration locally, with terragrunt installed:

1. Run one of the <env_type>/<env_type>.properties.sh files, to select which environment you are working with.
2. Navigate to the directory corresponding to the component you want to update
3. terragrunt init
4. terragrunt plan
5. terragrunt apply

It is also possible to run all configurations with the terragrunt *-all commands, from the top-level directory.

It is recommended to use the containerised teraform/terragrunt tooling, to ensure consistency with the automated CI build.

It is even more recommended to use the automated CI build directly.

### Bastion

To access an environment you will need to use the bastion host.

## GitHub Actions

An action to delete the branch after merge has been added.
Also an action that will tag when branch is merged to master
See https://github.com/anothrNick/github-tag-action

```
Bumping

Manual Bumping: Any commit message that includes #major, #minor, or #patch will trigger the respective version bump. If two or more are present, the highest-ranking one will take precedence.

Automatic Bumping: If no #major, #minor or #patch tag is contained in the commit messages, it will bump whichever DEFAULT_BUMP is set to (which is minor by default).

Note: This action will not bump the tag if the HEAD commit has already been tagged.
```

## Release / Deployments

The new process will include the addition of deploying a known version of this code using a tag from the git repo.
After the code is tested, code reviewed the merge of the feature branch to master will trigger the GitHub action resulting in git tag creation.
These tags can be progressed through the environments towards Production by specifying the tag to deploy.

The tag value is retrieved from AWS SSM Parameter Store. See https://github.com/ministryofjustice/delius-versions
The version retrieved from the AWS SSM Parameter Store is set by updating the tag value in the map `hmpps-delius-core-terraform` in `config/020-delius-core.tfvars` for the environment.

### Jenkins file

This jenkinsfile has two parameters (not to be confused with AWS SSM Parameters)
- CONFIG_BRANCH
- DCORE_BRANCH

This has been used to specify the branch to use in place of the default `master` branch. Going forward the default will be the Git tag or branch specified in the AWS SSM Parameter Store. However the option to override will still be available for development, debugging and hotfix situations.

*psuedo code*

```
if ("aws ssm parameter version" not empty and "DCORE_BRANCH" not defaultValue)
  set "delius core version" to "aws ssm parameter version"
else
  set "delius core version" to "DCORE_BRANCH"
else
  error
```
