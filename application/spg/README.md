# National Delius - WebLogic SPG domain

Supports the connectivity between National Delius and the external Community Rehabilitation Companies (CRCs), via JMS messaging through the Service Provider Gateway (SPG).

This terraform module defines a load-balanced WebLogic auto-scaling group with the NDelius and NDeliusSPG applications deployed, 
as well as an ActiveMQ broker to support JMS messaging between NDelius and the SPG broker.

## Resources
* `weblogic-spg.tf` - Module defining WebLogic ASG with an internal application load-balancer
* `nfs.tf` - NFS server that is mounted onto each WebLogic instance, to support shared ActiveMQ persistence
* `elb.tf` - Internal classic load-balancer on port 61617, sitting in front of the ActiveMQ broker

## Outputs
* `private_fqdn_spg_wls_internal_alb` - Private DNS name for the internal ALB eg. spg-app-internal.delius-core-dev.internal
* `public_fqdn_spg_wls_internal_alb` - Public DNS name for the internal ALB eg. spg-app-internal.dev.delius-core.probation.hmpps.dsd.io
* `private_fqdn_jms_broker` - Private DNS name for the internal ActiveMQ load-balancer eg. delius-jms.delius-core-dev.internal
* `public_fqdn_jms_broker` - Public DNS name for the internal ActiveMQ load-balancer eg. delius-jms.delius-core.probation.hmpps.dsd.io
