#
# Multi-region routing to serve requests from the nearest backend.
#

sub vcl_recv {
	if (geoip.continent_code ~ "(NA|SA|OC|AS)") {
		set req.backend = F_origin_us;
    set req.http.host = "origami-imageset-data-us.s3.amazonaws.com";

		if (!req.backend.healthy) {
			set req.backend = F_origin_eu;
      set req.http.host = "origami-imageset-data-eu.s3.amazonaws.com";
		}
	} else {
		set req.backend = F_origin_eu;
    set req.http.host = "origami-imageset-data-eu.s3.amazonaws.com";

		if (!req.backend.healthy) {
			set req.backend = F_origin_us;
      set req.http.host = "origami-imageset-data-us.s3.amazonaws.com";
		}
	}
}
