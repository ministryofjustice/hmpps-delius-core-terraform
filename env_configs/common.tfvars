route53_domain_private = "probation.hmpps.dsd.io"

whitelist_cidrs = ["217.33.148.210/32", "81.134.202.29/32"] # Studio, VPN

weblogic_domain_ports = {
  oid_admin         = "7005" #user admin
  oid_managed       = "7001" #not used
  oid_ldap          = "3060" #app talking to oid
  ndelius_admin     = "7001"
  ndelius_managed   = "9704"
  interface_admin   = "7001"
  interface_managed = "8080" #TODO: check port for api calls
  spg_admin         = "7001"
  spg_managed       = "8080" #TODO: check port for api calls
}

#TODO: allow JMX ports for weblogic domains from bastion or admin


#SPG has activeMQ running incomming
#database talks to activemq on spg weblogic domain
#spg talks to spg-weblogic-domain over activemq
