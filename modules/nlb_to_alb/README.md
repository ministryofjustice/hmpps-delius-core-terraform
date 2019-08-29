# nlb-to-alb

This module creates an external Network Load-Balancer with Elastic IP allocations across 3 availability zones. 

The NLB forwards TCP traffic on port 80 and port 443 to an auto-scaling group of HAProxy instances, 
which in turn forwards on to a DNS name provided in the variable `alb_fqdn`.

The reason this is required is to support linking a Network Load-Balancer to an Application Load-Balancer, 
while maintaining the ability to filter traffic based on Source IP. Without the HAProxy instances sitting between the 
two LBs, we would have be forced to register the ALB instances to the NLB by IP address (using the method in this [blog post](https://aws.amazon.com/blogs/networking-and-content-delivery/using-static-ip-addresses-for-application-load-balancers/)), 
which unfortunately means the Source IP would not be preserved.

See the following excerpt from the [AWS Documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html) on Source IP preservation:
> If you register targets by instance ID, the source IP addresses of the clients are preserved and provided to your applications. If you register targets by IP address, the source IP addresses are the private IP addresses of the load balancer nodes.