
sub vcl_recv {
  // Give every request a unique ID.
  set req.http.X-Request-Id = digest.hash_sha256(now randomstr(64) req.http.host req.url req.http.Fastly-Client-IP server.identity);

  // Avoid passing stale objects from Fastly shields to edge POPs.
  if (req.http.Fastly-FF) {
    set req.max_stale_while_revalidate = 0s;
  }

#FASTLY recv

  if (req.request != "HEAD" && req.request != "GET" && req.request != "FASTLYPURGE") {
    return(pass);
  }
}

sub vcl_fetch {
  // Serve stale objects on a backend error.
  if (http_status_matches(beresp.status, "500,502,503,504")) {
    if (stale.exists) {
      return(deliver_stale);
    }

    if (req.restarts < 1 && (req.request == "GET" || req.request == "HEAD")) {
      restart;
    }

    error 503;
  }

#FASTLY fetch

  if (req.request == "FASTLYPURGE") {
    set req.http.Fastly-Purge-Requires-Auth = "1";
  }

  if (http_status_matches(beresp.status, "500,502,503,504") && req.restarts < 1 && (req.request == "GET" || req.request == "HEAD")) {
    restart;
  }

  if (req.restarts > 0) {
    set beresp.http.Fastly-Restarts = req.restarts;
  }

  if (beresp.http.Set-Cookie) {
    set req.http.Fastly-Cachetype = "SETCOOKIE";
  }

  if (beresp.http.Cache-Control ~ "private") {
    set req.http.Fastly-Cachetype = "PRIVATE";
  }
}

sub vcl_hit {
#FASTLY hit

  if (!obj.cacheable) {
    return(pass);
  }
}

sub vcl_miss {
#FASTLY miss
}

sub vcl_deliver {
  // Serve stale objects on a backend error.
  if (http_status_matches(resp.status, "500,502,503,504") && stale.exists) {
    restart;
  }

#FASTLY deliver
}

sub vcl_error {
#FASTLY error

  if (http_status_matches(obj.status, "500,502,503,504") && stale.exists) {
    return(deliver_stale);
  }
}

sub vcl_pass {
#FASTLY pass
}

sub vcl_log {
#FASTLY log
}
