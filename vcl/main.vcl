#
# NOTE: The order of these includes is extremely important.
#

// The Fastly VCL boilerplate.
include "fastly-boilerplate.vcl";

sub vcl_recv {
  // Sort query parameters for a better cache hit rate.
  set req.url = boltsort.sort(req.url);
}

sub vcl_deliver {
  if (req.http.Fastly-Debug) {
    set resp.http.Debug-Backend = req.backend;
    set resp.http.Debug-Cache-State = fastly_info.state;
    set resp.http.Debug-Request-Header-True-Client-IP = req.http.True-Client-IP;
    set resp.http.Debug-Request-Header-User-Agent = req.http.User-Agent;
    set resp.http.Debug-Request-Header-X-Forwarded-For = req.http.X-Forwarded-For;
    set resp.http.Debug-Request-Id = req.http.X-Request-Id;
    set resp.http.Debug-Request-Restarts = req.restarts;
    set resp.http.Debug-Response-Header-Surrogate-Control = resp.http.Surrogate-Control;
    set resp.http.Debug-Url = req.url;
  } else {
    unset resp.http.Server;
    unset resp.http.Via;
    unset resp.http.X-Api;
    unset resp.http.X-Cache-Hits;
    unset resp.http.X-Cache-Policy;
    unset resp.http.X-Cache;
    unset resp.http.X-Powered-By;
    unset resp.http.X-Served-By;
    unset resp.http.X-StructureId;
    unset resp.http.X-StructureVersion;
    unset resp.http.X-Timer;
  }
}

// Route requests to the nearest backend.
include "multi-region-routing.vcl";
