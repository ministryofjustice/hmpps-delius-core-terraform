resource "aws_lb_listener_rule" "jsp_redirect_listener_rule" {
  count        = var.dual_run_with_sr28 ? 1 : 0
  listener_arn = module.weblogic.lb_listener_arn
  priority     = 2
  condition {
    path_pattern {
      values = ["/NDelius*.jsp"]
    }
  }
  action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/html"
      status_code  = "200"
      message_body = "<html lang=\"en\" class=\"bg-light h-100\"><head><title>National Delius</title><link href=\"https://maxcdn.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css\" rel=\"stylesheet\"></head><body class=\"bg-light h-100\"><div class=\"container\" style=\"max-width: 600px;\"><h1 class=\"text-center font-weight-light w-100 pt-5 pb-4\">National Delius</h1><div class=\"card card-body\"><div class=\"form-group\"><label class=\"control-label\" for=\"url\">The link to National Delius has recently changed. If you are following a bookmark, please update it to:</label><input id=\"url\" class=\"form-control\" type=\"text\" value=\"${module.weblogic.public_url}\"></div><div class=\"form-group\"><label>Redirecting you in <span id=\"timer\">10</span> seconds...</label></div></div></form></div><script> let timer = 10; setInterval(() => document.querySelector(\"#timer\").innerHTML = Math.max(--timer, 0), 1000); setTimeout(() => location.href = \"${module.weblogic.public_url}\", 10000);</script></body>"
    }
  }
}
