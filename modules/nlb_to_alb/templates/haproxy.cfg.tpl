defaults
    mode tcp
    timeout connect 10s
    timeout client 30s
    timeout server 30s

listen l1
    bind *:80
    server alb ${alb_fqdn}:80

listen l2
    bind *:443
    server alb ${alb_fqdn}:443