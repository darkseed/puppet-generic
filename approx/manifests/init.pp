class approx {
	package { "approx":
		ensure => installed,
	}

	service  { "approx":
		ensure => running,
		require => Package["approx"],
		subscribe => File["/etc/approx/approx.conf"],
	}

	file { "/etc/approx/approx.conf":
		source => "puppet://puppet/approx/approx.conf",
		mode => 644,
		owner => root,
		group => root,
		require => Package["approx"],
	}
}
