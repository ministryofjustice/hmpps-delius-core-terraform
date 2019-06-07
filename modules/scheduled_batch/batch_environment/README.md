# batch/standalone_ce terraform module
Creates the following:
- Single AWS Batch EC2 Compute Environment (CE)
- IAM Instance Role and Policy for ECS instances run as part of the CE
- Single Job Queue linked to this CE

Required Parameters:
- *$ce_name*: CE Name
- *$ce_policy*: Rendered IAM Instance Policy DOcument
- *$ce_instances*: List of target EC2 instance types for use in the CE
- *$ce_min_vcpu* && *$ce_max_vcpu*: Min & Max VCPU values
- *$ce_sg*: List of preexisting Security Groups to attach ECS instances to
- *$ce_subnets*: List of preexisting VPC subnets in which to run ECS instances
- *$ce_tags*: Map of K/V Tags to be applied to EC2 instanxces run as part of CE
