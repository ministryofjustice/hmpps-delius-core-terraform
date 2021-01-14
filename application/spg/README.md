# National Delius - WebLogic SPG domain

Supports the connectivity between National Delius and the external Community Rehabilitation Companies (CRCs), via JMS messaging through the Service Provider Gateway (SPG).

This terraform module defines a load-balanced WebLogic auto-scaling group with the NDelius and NDeliusSPG applications deployed, 
as well as an ActiveMQ broker to support JMS messaging between NDelius and the SPG broker.

## Resources
* `weblogic-spg.tf` - Module defining WebLogic ASG with an internal application load-balancer
* `efs.tf` - EFS server that is mounted onto each WebLogic instance, to support shared ActiveMQ persistence
* `elb.tf` - Internal classic load-balancer on port 61617, sitting in front of the ActiveMQ broker

## Architecture

![ActiveMQ](delius-core-activemq.svg)