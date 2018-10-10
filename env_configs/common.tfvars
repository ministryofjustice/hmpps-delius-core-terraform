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

weblogic_ebs = {
  oid_device_name       = "/dev/xvdc"
  oid_mount_point       = "/u01"
  ndelius_device_name   = "/dev/xvdc"
  ndelius_mount_point   = "/u01"
  interface_device_name = "/dev/xvdc"
  interface_mount_point = "/u01"
  spg_device_name       = "/dev/xvdc"
  spg_mount_point       = "/u01"
}

#TODO: allow JMX ports for weblogic domains from bastion or admin


#SPG has activeMQ running incomming
#database talks to activemq on spg weblogic domain
#spg talks to spg-weblogic-domain over activemq
#  # engineering
# dependencies_bucket_arn = "arn:aws:s3:::tf-eu-west-2-hmpps-eng-dev-artefacts-s3bucket"

# dev
dependencies_bucket_arn = "arn:aws:s3:::tf-eu-west-2-hmpps-eng-dev-delius-core-dependencies-s3bucket"
