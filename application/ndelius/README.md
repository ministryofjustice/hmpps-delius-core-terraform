# National Delius - WebLogic NDelius domain

> :memo: DEPRECATED. WebLogic servers have moved to ECS. See [/application/weblogic-app](/application/weblogic-app).

Supports the front-end application for National Delius.

This terraform module defines a load-balanced WebLogic auto-scaling group with the NDelius application deployed.

## Resources
* `weblogic-ndelius.tf` - Module defining WebLogic ASG with an internal application load-balancer
* `nlb.tf` - External network load-balancer to forward traffic on to the internal ALB via a HAProxy ASG.
This is to support static elastic IP addresses that can be whitelisted in external firewalls, whilst maintaining the 
ability for us to also whitelist inbound CIDR ranges.

## Outputs
* `private_fqdn_spg_wls_internal_alb` - Private DNS name for the internal ALB eg. ndelius-app-internal.delius-core-dev.internal
* `public_fqdn_spg_wls_internal_alb` - Public DNS name for the internal ALB eg. ndelius-app-internal.dev.delius-core.probation.hmpps.dsd.io
* `private_fqdn_ndelius_external_nlb` - Private DNS name for the external NLB eg. ndelius.delius-core-dev.internal
* `public_fqdn_ndelius_external_nlb` - Public DNS name for the external NLB eg. ndelius.delius-core.probation.hmpps.dsd.io
