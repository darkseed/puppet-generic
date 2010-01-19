class dnsmasq {
	package {
		"dnsmasq":
			ensure => present;
	}

	service {
		"dnsmasq":
			hasstatus => true,
			hasrestart => true,
			ensure => running,
			require => Package["dnsmasq"];
	}

	file {
		"/etc/dnsmasq.conf":
			owner => "root",
			group => "root",
			mode => 644,
			notify => Service["dnsmasq"];
		"/etc/default/dnsmasq":
			owner => "root",
			group => "root",
			mode => 644,
			notify => Service["dnsmasq"];
	}
}
