# LDAP

Creates a private auto-scaling group containing instances that will be bootstrapped to run the National 
Delius LDAP service.

## Resources
* `asg.tf` - Launch configuration and auto-scaling group
* `elb.tf` - Internal classic load balancer
* `dns.tf` - Internal Route53 DNS entry for the load balancer
