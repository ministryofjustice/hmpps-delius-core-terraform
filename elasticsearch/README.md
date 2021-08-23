# Elasticsearch
An Elasticsearch domain used for indexing and searching contact records within the Delius system.

The index will be populated by a procedure in the Delius database, 
and a search endpoint is provided by Delius API for surfacing the indexed data to authorised systems.

## Configuration
Configure the AWS resources using the `default_contact_search_config` and `contact_search_config` variables in the [hmpps-env-configs](https://github.com/ministryofjustice/hmpps-env-configs) repository.

## Security
Security groups control network access to the domain endpoints on port 443. Currently, the domain can be accessed from the Delius database, the Delius API, and the Bastion.

All data is encrypted at rest and in-transit using the default account KMS key.

## Availability
The domain will be spread across up to 3 availability zones, depending on the `instance_count` variable.

## Backups
An automated snapshot of the data is taken at the hour specified in the `automated_snapshot_start_hour` variable.

## Monitoring
Elasticsearch pushes application logs and metrics to CloudWatch. 
Various alarms are defined in [cloudwatch.tf](cloudwatch.tf), based on the [AWS best practices](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/cloudwatch-alarms.html).

## Kibana Access
The Terraform outputs will contain the Kibana endpoint URL, see [outputs.tf](outputs.tf).

Access to the endpoint must be proxied/tunnelled through the Bastion instance.
Either:
* Set up a SOCKS proxy via the Bastion (`ssh -D8185 moj_dev_bastion`) and use a browser proxy extension e.g. FoxyProxy, or
* Forward port 443 to your local machine (`ssh moj_dev_bastion -L8443:${kibana_endpoint}:443`) and access using https://localhost:8443.
