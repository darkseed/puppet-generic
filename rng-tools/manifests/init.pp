class rng-tools {
	package { ["rng-tools","reseed"]:
		ensure => installed,
	}

	file { "/etc/default/rng-tools":
		source  => "puppet:///modules/rng-tools/default/rng-tools",
		notify  => Service["rng-tools"],
		require => Package["rng-tools"],
	}

	service { "rng-tools":
		ensure  => running,
		pattern => "/usr/sbin/rngd",
		require => File["/etc/default/rng-tools"],
	}
}
