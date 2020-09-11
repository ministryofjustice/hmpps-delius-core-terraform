# Weblogic Admin Only

This module creates an auto-scaling group of EC2 instances, each configured to be a WebLogic AdminServer.
An internal application load balancer is created with restricted paths, to only allow traffic in to the NDelius application - this restriction is required to block access to the WebLogic console and to protect ourselves from any CVEs present in administrative WebLogic endpoints. 
