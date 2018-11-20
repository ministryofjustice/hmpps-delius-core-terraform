The Delius Core application servers requires a role and policy for access to private S3 buckets.

Use the following attirbute

```
iam_instance_profile = "${local.environment_name}-server-provison-ec2-role"
```
