#
# Multi-region routing to serve requests from the nearest backend.
#

sub vcl_recv {
	if (server.identity ~ "-IAD$") {
		set req.backend = F_origin_us;

		if (!req.backend.healthy) {
			set req.backend = F_origin_eu;
		}
	} else if (server.identity ~ "-LCY$") {
		set req.backend = F_origin_eu;

		if (!req.backend.healthy) {
			set req.backend = F_origin_us;
		}
	} else if (geoip.continent_code ~ "(NA|SA|OC|AS)") {
		set req.backend = ssl_shield_iad_va_us;

		if (!req.backend.healthy) {
			set req.backend = ssl_shield_london_city_uk;
		}
	} else {
		set req.backend = ssl_shield_london_city_uk;

		if (!req.backend.healthy) {
			set req.backend = ssl_shield_iad_va_us;
		}
	}
}
