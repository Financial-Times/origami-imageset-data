// Prevent automatic upgrades to new major versions that may contain breaking changes.
provider "fastly" {
  version = "0.1.2"
}

resource "fastly_service_v1" "origami_imageset_data" {
  // The descriptive name for this Fastly service.
  name = "Origami Imageset Data (github.com/Financial-Times/origami-imageset-data)"

  domain {
    name = "origami-images.ft.com"
  }

  backend {
    # Name for this Backend. Must be unique to this Service.
    name = "origami_imageset_data_us"

    # An IPv4, hostname, or IPv6 address for the Backend.
    address = "origami-imageset-data-us.s3.amazonaws.com"

    # Denotes if this Backend should be included in the pool of backends that requests are load balanced against.
    auto_loadbalance = false

    # How long to wait between bytes in milliseconds.
    between_bytes_timeout = 10000

    # How long to wait for a timeout in milliseconds.
    connect_timeout = 1000

    # Number of errors to allow before the Backend is marked as down.
    error_threshold = 0

    # How long to wait for the first bytes in milliseconds.
    first_byte_timeout = 15000

    # Name of a defined healthcheck to assign to this backend
    healthcheck = "origami_imageset_data_us_healthcheck"

    # Maximum number of connections for this Backend.
    max_conn = 200

    # The port number on which the Backend responds.
    port = 443

    # Be strict about checking SSL certs.
    ssl_check_cert = true

    # Overrides ssl_hostname, but only for cert verification. Does not affect SNI at all.
    ssl_cert_hostname = "*.s3.amazonaws.com"
  }

  healthcheck {
    # A unique name to identify this Healthcheck.
    name = "origami_imageset_data_us_healthcheck"

    # Address of the host to check.
    host = "origami-imageset-data-us.s3.amazonaws.com"

    # The path to check.
    path = "/__gtg"

    # How often to run the Healthcheck in milliseconds.
    check_interval = 60000

    # The status code expected from the host.
    expected_response = 200

    # Whether to use version 1.0 or 1.1 HTTP.
    http_version = "1.1"

    # When loading a config, the initial number of probes to be seen as OK.
    initial = 1

    # Which HTTP method to use.
    method = "HEAD"

    # How many Healthchecks must succeed to be considered healthy.
    threshold = 1

    # Timeout in milliseconds.
    timeout = 5000

    # The number of most recent Healthcheck queries to keep for this Healthcheck.
    window = 2
  }

  backend {
    # Name for this Backend. Must be unique to this Service.
    name = "origami_imageset_data_eu"

    # An IPv4, hostname, or IPv6 address for the Backend.
    address = "origami-imageset-data-eu.s3.amazonaws.com"

    # Denotes if this Backend should be included in the pool of backends that requests are load balanced against.
    auto_loadbalance = false

    # How long to wait between bytes in milliseconds.
    between_bytes_timeout = 10000

    # How long to wait for a timeout in milliseconds.
    connect_timeout = 1000

    # Number of errors to allow before the Backend is marked as down.
    error_threshold = 0

    # How long to wait for the first bytes in milliseconds.
    first_byte_timeout = 15000

    # Name of a defined healthcheck to assign to this backend
    healthcheck = "origami_imageset_data_eu_healthcheck"

    # Maximum number of connections for this Backend.
    max_conn = 200

    # The port number on which the Backend responds.
    port = 443

    # Be strict about checking SSL certs.
    ssl_check_cert = true

    # Overrides ssl_hostname, but only for cert verification. Does not affect SNI at all.
    ssl_cert_hostname = "*.s3.amazonaws.com"
  }

  healthcheck {
    # A unique name to identify this Healthcheck.
    name = "origami_imageset_data_eu_healthcheck"

    # Address of the host to check.
    host = "origami-imageset-data-eu.s3.amazonaws.com"

    # The path to check.
    path = "/__gtg"

    # How often to run the Healthcheck in milliseconds.
    check_interval = 60000

    # The status code expected from the host.
    expected_response = 200

    # Whether to use version 1.0 or 1.1 HTTP.
    http_version = "1.1"

    # When loading a config, the initial number of probes to be seen as OK.
    initial = 1

    # Which HTTP method to use.
    method = "HEAD"

    # How many Healthchecks must succeed to be considered healthy.
    threshold = 1

    # Timeout in milliseconds.
    timeout = 5000

    # The number of most recent Healthcheck queries to keep for this Healthcheck.
    window = 2
  }

  // Logging to S3, see https://docs.fastly.com/guides/streaming-logs/custom-log-formats for formats.
  # s3logging {
  #   name           = "S3"
  #   bucket_name    = "ft-origami-imageset-data-cdn-logs"
  #   path           = "/origami_imageset_data/production/"
  #   period         = "300"
  #   gzip_level     = 9
  #   format_version = 2
  #   format         = "%v [%{%Y-%m-%d %H:%M:%S}t.%{msec_frac}t] \"%r\" \"%{Location}o\" \"%{Referer}i\" %>s %B %{tls.client.protocol}V %{fastly_info.state}V %X"
  #   message_type   = "blank"
  # }


  #
  # START PURGING
  #

  header {
    # Unique name for this header attribute.
    name = "Require API key for purging"

    # The Header manipulation action to take; must be one of set, append, delete, regex, or regex_repeat.
    action = "set"

    # Do not add the header if it is already present.
    ignore_if_set = false

    # The Request type on which to apply the selected Action; must be one of request, fetch, cache or response.
    type = "request"

    # The name of the header that is going to be affected by the Action.
    destination = "http.Fastly-Purge-Requires-Auth"

    # Variable to be used as a source for the header content.
    source = "\"1\""
  }

  #
  # END PURGING
  #

  #
  # START ROUTING
  #
  condition {
    # The unique name for the condition.
    name = "default to EU"

    # A number used to determine the order in which multiple conditions execute. Lower numbers execute first.
    priority = 1

    # The statement used to determine if the condition is met.
    statement = "req.http.host"

    # Type of condition, either REQUEST (req), RESPONSE (req, resp), or CACHE (req, beresp).
    type = "REQUEST"
  }
  condition {
    # The unique name for the condition.
    name = "decided to switch to US"

    # A number used to determine the order in which multiple conditions execute. Lower numbers execute first.
    priority = 2

    # The statement used to determine if the condition is met.
    statement = "randombool(1, 2)"

    # Type of condition, either REQUEST (req), RESPONSE (req, resp), or CACHE (req, beresp).
    type = "REQUEST"
  }
  header {
    # Unique name for this header attribute.
    name = "use EU backend"

    # The Header manipulation action to take; must be one of set, append, delete, regex, or regex_repeat.
    action = "set"

    # Do not add the header if it is already present.
    ignore_if_set = false

    # The Request type on which to apply the selected Action; must be one of request, fetch, cache or response.
    type = "request"

    # The name of the header that is going to be affected by the Action.
    destination = "backend"

    # Name of already defined condition to apply.
    request_condition = "default to EU"

    # Variable to be used as a source for the header content.
    source = "F_origami_imageset_data_eu"
  }
  header {
    # Unique name for this header attribute.
    name = "use EU host"

    # The Header manipulation action to take; must be one of set, append, delete, regex, or regex_repeat.
    action = "set"

    # Do not add the header if it is already present.
    ignore_if_set = false

    # The Request type on which to apply the selected Action; must be one of request, fetch, cache or response.
    type = "request"

    # The name of the header that is going to be affected by the Action.
    destination = "http.host"

    # Name of already defined condition to apply.
    request_condition = "default to EU"

    # Variable to be used as a source for the header content.
    source = "\"origami-imageset-data-eu.s3.amazonaws.com\""
  }
  header {
    # Unique name for this header attribute.
    name = "use US backend"

    # The Header manipulation action to take; must be one of set, append, delete, regex, or regex_repeat.
    action = "set"

    # Do not add the header if it is already present.
    ignore_if_set = false

    # The Request type on which to apply the selected Action; must be one of request, fetch, cache or response.
    type = "request"

    # The name of the header that is going to be affected by the Action.
    destination = "backend"

    # Name of already defined condition to apply.
    request_condition = "decided to switch to US"

    # Variable to be used as a source for the header content.
    source = "F_origami_imageset_data_us"
  }
  header {
    # Unique name for this header attribute.
    name = "use US host"

    # The Header manipulation action to take; must be one of set, append, delete, regex, or regex_repeat.
    action = "set"

    # Do not add the header if it is already present.
    ignore_if_set = false

    # The Request type on which to apply the selected Action; must be one of request, fetch, cache or response.
    type = "request"

    # The name of the header that is going to be affected by the Action.
    destination = "http.host"

    # Name of already defined condition to apply.
    request_condition = "decided to switch to US"

    # Variable to be used as a source for the header content.
    source = "\"origami-imageset-data-us.s3.amazonaws.com\""
  }

  #
  # END ROUTING
  #


  #
  # START FAILOVER
  #

  condition {
    # The unique name for the condition.
    name = "EU backend down"

    # A number used to determine the order in which multiple conditions execute. Lower numbers execute first.
    priority = 3

    # The statement used to determine if the condition is met.
    statement = "req.backend == F_origami_imageset_data_eu && !req.backend.healthy"

    # Type of condition, either REQUEST (req), RESPONSE (req, resp), or CACHE (req, beresp).
    type = "REQUEST"
  }
  condition {
    # The unique name for the condition.
    name = "US backend down"

    # A number used to determine the order in which multiple conditions execute. Lower numbers execute first.
    priority = 3

    # The statement used to determine if the condition is met.
    statement = "req.backend == F_origami_imageset_data_us && !req.backend.healthy"

    # Type of condition, either REQUEST (req), RESPONSE (req, resp), or CACHE (req, beresp).
    type = "REQUEST"
  }
  header {
    # Unique name for this header attribute.
    name = "failover to EU backend"

    # The Header manipulation action to take; must be one of set, append, delete, regex, or regex_repeat.
    action = "set"

    # Do not add the header if it is already present.
    ignore_if_set = false

    # The Request type on which to apply the selected Action; must be one of request, fetch, cache or response.
    type = "request"

    # The name of the header that is going to be affected by the Action.
    destination = "backend"

    # Name of already defined condition to apply.
    request_condition = "US backend down"

    # Variable to be used as a source for the header content.
    source = "F_origami_imageset_data_eu"
  }
  header {
    # Unique name for this header attribute.
    name = "failover to EU host"

    # The Header manipulation action to take; must be one of set, append, delete, regex, or regex_repeat.
    action = "set"

    # Do not add the header if it is already present.
    ignore_if_set = false

    # The Request type on which to apply the selected Action; must be one of request, fetch, cache or response.
    type = "request"

    # The name of the header that is going to be affected by the Action.
    destination = "http.host"

    # Name of already defined condition to apply.
    request_condition = "US backend down"

    # Variable to be used as a source for the header content.
    source = "\"origami-imageset-data-eu.s3.amazonaws.com\""
  }
  header {
    # Unique name for this header attribute.
    name = "failover to US backend"

    # The Header manipulation action to take; must be one of set, append, delete, regex, or regex_repeat.
    action = "set"

    # Do not add the header if it is already present.
    ignore_if_set = false

    # The Request type on which to apply the selected Action; must be one of request, fetch, cache or response.
    type = "request"

    # The name of the header that is going to be affected by the Action.
    destination = "backend"

    # Name of already defined condition to apply.
    request_condition = "EU backend down"

    # Variable to be used as a source for the header content.
    source = "F_origami_imageset_data_us"
  }
  header {
    # Unique name for this header attribute.
    name = "failover to US host"

    # The Header manipulation action to take; must be one of set, append, delete, regex, or regex_repeat.
    action = "set"

    # Do not add the header if it is already present.
    ignore_if_set = false

    # The Request type on which to apply the selected Action; must be one of request, fetch, cache or response.
    type = "request"

    # The name of the header that is going to be affected by the Action.
    destination = "http.host"

    # Name of already defined condition to apply.
    request_condition = "EU backend down"

    # Variable to be used as a source for the header content.
    source = "\"origami-imageset-data-us.s3.amazonaws.com\""
  }

  #
  # END FAILOVER
  #


  #
  # START DEBUG
  #

  condition {
    # The unique name for the condition.
    name = "debug"

    # A number used to determine the order in which multiple conditions execute. Lower numbers execute first.
    priority = 1

    # The statement used to determine if the condition is met.
    statement = "req.http.fastly-debug"

    # Type of condition, either REQUEST (req), RESPONSE (req, resp), or CACHE (req, beresp).
    type = "RESPONSE"
  }
  header {
    # Unique name for this header attribute.
    name = "return host"

    # The Header manipulation action to take; must be one of set, append, delete, regex, or regex_repeat.
    action = "set"

    # Do not add the header if it is already present.
    ignore_if_set = false

    # The Request type on which to apply the selected Action; must be one of request, fetch, cache or response.
    type = "response"

    # The name of the header that is going to be affected by the Action.
    destination = "http.Fastly-Debug-Backend"

    # Name of already defined condition to apply.
    response_condition = "debug"

    # Variable to be used as a source for the header content.
    source = "req.http.host"
  }

  #
  # END DEBUG
  #
}
