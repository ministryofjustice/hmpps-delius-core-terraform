# pingdom

[pingdom](https://pingdom.com) is used to periodically check the status of the delius application.

This module defines the endpoints for pingdom to check, as well as a lambda that will keep a specified security group 
up-to-date with whitelisted pingdom probe IPs.

## Resources
* `checks.tf` - Pingdom endpoint checks
* `lambda.tf` - Lambda function to update the `pingdom_in` security group with Pingdom probe IPs
* `iam.tf` - IAM role to attach to the lambda
* `sns.tf` - SNS topic subscription to trigger the lambda function when pingdom IPs are published
