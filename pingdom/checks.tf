resource "pingdom_check" "ndelius_frontend" {
  type          = "http"
  name          = "National Delius - Front-end (${var.environment_name})"
  host          = "${data.terraform_remote_state.ndelius.public_fqdn_ndelius_wls_external}"
  url           = "/NDelius-war/delius/JSP/healthcheck.jsp"
  resolution    = 1
  encryption    = "true"
  probefilters  = "region:EU"
  publicreport  = "${contains(var.pingdom_publicreports, "ndelius_frontend")}"
}
