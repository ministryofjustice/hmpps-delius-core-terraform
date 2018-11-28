The Delius Core Application

Instances will not be terminated when a newer AMI is availible. To update instance with new AMI the taint command needs to be run.

For instance in modules

```
terragrunt taint -module="ndelius" aws_instance.admin
terragrunt taint -module="ndelius" aws_instance.managed
terragrunt taint -module="interface" aws_instance.admin
terragrunt taint -module="interface" aws_instance.managed
terragrunt taint -module="spg" aws_instance.admin
terragrunt taint -module="spg" aws_instance.managed
```
