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
