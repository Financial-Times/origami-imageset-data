#
# Multi-region routing to serve requests from the nearest backend.
#

sub vcl_recv {
	if (geoip.continent_code ~ "(NA|SA|OC|AS)") {
		set req.backend = F_origin_us;

		if (!req.backend.healthy) {
			set req.backend = F_origin_eu;
		}
	} else {
		set req.backend = F_origin_eu;

		if (!req.backend.healthy) {
			set req.backend = F_origin_us;
		}
	}
}
