# Delius-Core Terraform

Infrastructure and provisioning of the National Delius probation case management system, and its core supporting 
services, into the Delius AWS environments.

![Architecture diagram for the core Delius components](architecture-diagram.svg "Delius-Core AWS Infrastructure Diagram")

For more information on the Delius infrastructure components, browse the [Confluence pages](https://dsdmoj.atlassian.net/wiki/spaces/DAM). 

## Dependencies
* [Environment config files](https://github.com/ministryofjustice/hmpps-env-configs) (see [#configuration](#configuration)).
* [Common resources (e.g. VPC)](https://github.com/ministryofjustice/hmpps-delius-network-terraform) should already exist in the target environment.
* IAM Credentials, with permissions to assume the `terraform` role.

## Components
### Applications
The following applications run as containerized services on the shared [ECS cluster](https://dsdmoj.atlassian.net/wiki/spaces/DAM/pages/3107979730/ECS+Cluster).
* [application/weblogic-app](application/weblogic-app) - Delius application front-end
* [application/weblogic-eis](application/weblogic-eis) - Delius external interface services i.e. API endpoints for IAPS, OASys, DSS, and CaseNotes.
* [application/pwm](application/pwm) - Password Reset Tool - [Confluence Page](https://dsdmoj.atlassian.net/wiki/spaces/DAM/pages/2116092086/PWM+-+Password+Reset)
* [application/umt](application/umt) - User Management Tool
* [application/community-api](application/community-api)
* [application/new-tech](application/new-tech)
* [application/pdf-generator](application/pdf-generator)
* [application/gdpr](application/gdpr)
* [application/merge](application/merge)
### Integrations
* [lambda](lambda) - Lambda functions to handle HMPPS domain events
* [batch/dss](batch/dss) - NOMIS/OFFLOC Data Share System - [Confluence Page](https://dsdmoj.atlassian.net/wiki/spaces/DAM/pages/1488486513/Data+Share+System+DSS)
### Data
* [database_failover](database_failover) - Delius Primary OracleDB
* [database_standbydb1](database_standbydb1) - Delius Standby OracleDB
* [database_standbydb2](database_standbydb2) - Delius Standby OracleDB
* [application/ldap](application/ldap) - LDAP User Data Store - [Confluence Page](https://dsdmoj.atlassian.net/wiki/spaces/DAM/pages/2032271398/LDAP)
* [elasticsearch](elasticsearch) - Elasticsearch index, populated from the Delius databases
### Monitoring
* [access-logs](access-logs) - Bucket for storing LB access logs
* [alerts](alerts) - Common Slack alerting lambdas
* [dashboards](dashboards) - CloudWatch dashboards
### Security
* [key_profile](key_profile) - KMS Keys and Instance Profiles
* [security-groups](security-groups) - Security Groups and Rules

## Usage
### Local Development
The [run.sh](run.sh) script, located in the root of the project, can be used to test and apply Terraform changes from 
your local environment. This is used to run Terragrunt commands in the [HMPPS Terraform Builder](https://github.com/ministryofjustice/hmpps-engineering-tools/tree/master/terraform-builder-0-12) 
Docker container, with the environment configuration mounted in the right place.

We recommend creating an alias for the run.sh script, so it can be used for applying other HMPPS Terraform projects:
```shell
alias tg='AWS_PROFILE=hmpps_token /path/to/run.sh'
```

#### Examples:
* Fetch configuration repository:
```shell
git clone https://github.com/ministryofjustice/hmpps-env-configs ../hmpps-env-configs
```
* Plan changes to the Delius Database in the Dev environment:
```shell
ENVIRONMENT=delius-core-dev COMPONENT=database_failover tg plan
```
* Plan and apply changes to the Community-API service in the Test account:
```shell
ENVIRONMENT=delius-test COMPONENT=application/community-api tg plan
ENVIRONMENT=delius-test COMPONENT=application/community-api tg apply
```
* Apply _everything_:
```shell
ENVIRONMENT=delius-core-dev tg apply-all
```

### Continuous Integration
Any Pull Request created in this repository will trigger a CodePipeline execution to deploy your changes to the 
`delius-core-dev` environment. This allows quick verification that the proposed changes work as intended, and adds a 
status check in GitHub to indicate whether the deployment was successful.

Once a Pull Request has been approved and merged, the repository will be tagged automatically by a GitHub Action defined
here: [tag-master-branch-on-merge.yaml](.github/workflows/tag-master-branch-on-merge.yaml).

The [delius-core-terraform](https://eu-west-2.console.aws.amazon.com/codesuite/codepipeline/pipelines/delius-core-terraform/view?region=eu-west-2) 
CodePipeline (in the Engineering-Dev account) will then roll the changes out to all environments, from development to
production, requesting approval for significant changes in the [#delius-alerts-deliuscore-nonprod](https://mojdt.slack.com/archives/CRMJZ0PGB) 
and [#delius-alerts-deliuscore-production](https://mojdt.slack.com/archives/CRMK94R8B) Slack channels.

* Terraform CodePipeline: [deploy-infrastructure.tf](https://github.com/ministryofjustice/hmpps-delius-pipelines/blob/master/components/delius-core/deploy-infrastructure.tf)
* Cross-Account CodePipeline: [delius-core-terraform.tf](https://github.com/ministryofjustice/hmpps-delius-pipelines/blob/master/engineering/deployments/delius-core-terraform-pipeline.tf)

The [delius-versions](https://github.com/ministryofjustice/delius-versions) repository will be updated with the tagged 
version after deployment, and the current version for each environment will appear on the [Delius Versions Dashboard](https://ministryofjustice.github.io/delius-versions-dashboard) 
in the `Infrastructure` column.

## Configuration
Environment configuration files can be found in the [hmpps-env-configs](https://github.com/ministryofjustice/hmpps-env-configs)
repository. These files should be made available in the `env_configs` directory, before running any Terragrunt commands.

```shell
# 1. Fetch environment configuration
git clone https://github.com/ministryofjustice/hmpps-env-configs ../hmpps-env-configs

# 2. Create a symbolic link (this part is handled automatically in the run.sh script)
ln -s -f ../hmpps-env-configs env_configs
```

## Contact
For any issues, please contact the Delius Infrastructure Support team via the [#delius_infra_support](https://mojdt.slack.com/archives/CNXK9893K) Slack channel.
Or feel free to create a [new issue](https://github.com/ministryofjustice/hmpps-delius-core-terraform/issues/new) in this repository.
