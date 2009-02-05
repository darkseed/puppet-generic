class thttpd {
	package { "thttpd":
		ensure => installed,
	}

	service { "thttpd":
		ensure => running,
		require => Package["thttpd"],
	}

	file { "/etc/thttpd/thttpd.conf":
		source => "puppet://puppet/thttpd/thttpd.conf",
		owner => "root",
		group => "root",
		mode => 644,
		require => [Package["thttpd"], File["/srv/www"]],
		notify => Service["thttpd"],
	}

	file { "/srv/www":
		ensure => directory,
		owner => "root",
		group => "root",
		mode => 755,
	}
}
