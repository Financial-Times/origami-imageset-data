provider "fastly" {}

resource "fastly_service_v1" "origami_imageset_data" {
  name = "Origami Imageset Data (github.com/Financial-Times/origami-imageset-data)"

  domain {
    name = "origami-images.ft.com"
  }

  backend {
    name              = "origin_us"
    address           = "origami-imageset-data-us.s3.amazonaws.com"
    auto_loadbalance  = false
    healthcheck       = "origin_us_healthcheck"
    port              = 443
    ssl_cert_hostname = "*.s3.amazonaws.com"
  }

  healthcheck {
    name           = "origin_us_healthcheck"
    host           = "origami-imageset-data-us.s3.amazonaws.com"
    path           = "/__gtg"
    check_interval = 60000
    timeout        = 5000
  }

  backend {
    name              = "origin_eu"
    address           = "origami-imageset-data-eu.s3.amazonaws.com"
    auto_loadbalance  = false
    healthcheck       = "origin_eu_healthcheck"
    port              = 443
    ssl_cert_hostname = "*.s3.amazonaws.com"
  }

  healthcheck {
    name           = "origin_eu_healthcheck"
    host           = "origami-imageset-data-eu.s3.amazonaws.com"
    path           = "/__gtg"
    check_interval = 60000
    timeout        = 5000
  }

  gzip {
    name          = "Compression Policy"
    extensions    = ["css", "js", "html", "eot", "ico", "otf", "ttf", "json", "svg"]
    content_types = ["text/html", "application/x-javascript", "text/css", "application/javascript", "text/javascript", "application/json", "application/vnd.ms-fontobject", "application/x-font-opentype", "application/x-font-truetype", "application/x-font-ttf", "application/xml", "font/eot", "font/opentype", "font/otf", "image/svg+xml", "image/vnd.microsoft.icon", "text/plain", "text/xml"]
  }

  vcl {
    name    = "main.vcl"
    content = file("${path.module}/../vcl/main.vcl")
    main    = true
  }

  vcl {
    name    = "fastly-boilerplate.vcl"
    content = file("${path.module}/../vcl/fastly-boilerplate.vcl")
  }

  vcl {
    name    = "multi-region-routing.vcl"
    content = file("${path.module}/../vcl/multi-region-routing.vcl")
  }

  # waf settings
  condition {
    name      = "WAF_Prefetch"
    priority  = 10
    statement = "req.backend.is_origin && !req.http.rqpass"
    type      = "PREFETCH"
  }
  condition {
    name      = "waf-soc-logging"
    priority  = 10
    statement = "waf.executed"
    type      = "RESPONSE"
  }
  condition {
    name      = "false"
    priority  = 10
    statement = "!req.url"
    type      = "REQUEST"
  }
  response_object {
    name              = "WAF_Response"
    response          = "Forbidden"
    status            = "403"
    content           = "{ \"Access Denied\" : \"\"} req.http.x_request_id {\"\" }"
    content_type      = "application/json"
    request_condition = "false"
  }
}
