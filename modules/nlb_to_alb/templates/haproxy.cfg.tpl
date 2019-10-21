defaults
    mode tcp
    timeout connect 30s
    timeout client 5m
    timeout server 5m

resolvers vpcresolver
    nameserver awsdns ${aws_nameserver}:53
    resolve_retries 30
    timeout retry 1s
    hold valid 10s

listen l1
    bind *:80
    server httpalb ${alb_fqdn}:80 check resolvers vpcresolver

listen l2
    bind *:443
    server httpsalb ${alb_fqdn}:443 check resolvers vpcresolver
