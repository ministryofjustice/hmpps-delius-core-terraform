The Delius Core application servers require some specific policies for access to private S3 buckets.

This role enables the EC2 instance that have the role profile applied to access an S3 bucket defined and managed in the github.com:ministryofjustice/hmpps-engineering-platform-terraform project under the
*delius-core* directory.

There is a requirement for the bucket arn to be define in a variable *dependencies_bucket_arn* which is located in this project's file *env_configs/common.tfvars*

Additional policies can be added when necessary.
