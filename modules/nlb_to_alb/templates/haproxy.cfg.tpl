defaults
    mode tcp
    timeout connect 30s
    timeout client 5m
    timeout server 5m

listen l1
    bind *:80
    server alb ${alb_fqdn}:80 init-addr last,libc,none

listen l2
    bind *:443
    server alb ${alb_fqdn}:443 init-addr last,libc,none