provider "fastly" {
  version = "0.1.2"
}

resource "fastly_service_v1" "origami_imageset_data" {
  name = "Origami Imageset Data (github.com/Financial-Times/origami-imageset-data)"

  domain {
    name = "origami-images.ft.com"
  }

  backend {
    name              = "origami_imageset_data_us"
    address           = "origami-imageset-data-us.s3.amazonaws.com"
    auto_loadbalance  = false
    healthcheck       = "origami_imageset_data_us_healthcheck"
    port              = 443
    ssl_cert_hostname = "*.s3.amazonaws.com"
  }

  healthcheck {
    name           = "origami_imageset_data_us_healthcheck"
    host           = "origami-imageset-data-us.s3.amazonaws.com"
    path           = "/__gtg"
    check_interval = 60000
  }

  backend {
    name              = "origami_imageset_data_eu"
    address           = "origami-imageset-data-eu.s3.amazonaws.com"
    auto_loadbalance  = false
    healthcheck       = "origami_imageset_data_eu_healthcheck"
    port              = 443
    ssl_cert_hostname = "*.s3.amazonaws.com"
  }

  healthcheck {
    name           = "origami_imageset_data_eu_healthcheck"
    host           = "origami-imageset-data-eu.s3.amazonaws.com"
    path           = "/__gtg"
    check_interval = 60000
  }

  header {
    name        = "Require API key for purging"
    action      = "set"
    type        = "request"
    destination = "http.Fastly-Purge-Requires-Auth"
    source      = "\"1\""
  }

  condition {
    name      = "default to EU"
    priority  = 1
    statement = "req.http.host"
    type      = "REQUEST"
  }

  condition {
    name      = "decided to switch to US"
    priority  = 2
    statement = "randombool(1, 2)"
    type      = "REQUEST"
  }

  header {
    name              = "use EU backend"
    action            = "set"
    type              = "request"
    destination       = "backend"
    request_condition = "default to EU"
    source            = "F_origami_imageset_data_eu"
  }

  header {
    name              = "use EU host"
    action            = "set"
    type              = "request"
    destination       = "http.host"
    request_condition = "default to EU"
    source            = "\"origami-imageset-data-eu.s3.amazonaws.com\""
  }

  header {
    name              = "use US backend"
    action            = "set"
    type              = "request"
    destination       = "backend"
    request_condition = "decided to switch to US"
    source            = "F_origami_imageset_data_us"
  }

  header {
    name              = "use US host"
    action            = "set"
    type              = "request"
    destination       = "http.host"
    request_condition = "decided to switch to US"
    source            = "\"origami-imageset-data-us.s3.amazonaws.com\""
  }

  condition {
    name      = "EU backend down"
    priority  = 3
    statement = "req.backend == F_origami_imageset_data_eu && !req.backend.healthy"
    type      = "REQUEST"
  }

  condition {
    name      = "US backend down"
    priority  = 3
    statement = "req.backend == F_origami_imageset_data_us && !req.backend.healthy"
    type      = "REQUEST"
  }

  header {
    name              = "failover to EU backend"
    action            = "set"
    type              = "request"
    destination       = "backend"
    request_condition = "US backend down"
    source            = "F_origami_imageset_data_eu"
  }

  header {
    name              = "failover to EU host"
    action            = "set"
    type              = "request"
    destination       = "http.host"
    request_condition = "US backend down"
    source            = "\"origami-imageset-data-eu.s3.amazonaws.com\""
  }

  header {
    name              = "failover to US backend"
    action            = "set"
    type              = "request"
    destination       = "backend"
    request_condition = "EU backend down"
    source            = "F_origami_imageset_data_us"
  }

  header {
    name              = "failover to US host"
    action            = "set"
    type              = "request"
    destination       = "http.host"
    request_condition = "EU backend down"
    source            = "\"origami-imageset-data-us.s3.amazonaws.com\""
  }

  condition {
    name      = "debug"
    priority  = 1
    statement = "req.http.fastly-debug"
    type      = "RESPONSE"
  }

  header {
    name               = "return host"
    action             = "set"
    type               = "response"
    destination        = "http.Fastly-Debug-Backend"
    response_condition = "debug"
    source             = "req.http.host"
  }
}
