class rng-tools {
	kpackage { "rng-tools":
		ensure => installed;
	}

	kfile { "/etc/default/rng-tools":
		source  => "rng-tools/default/rng-tools",
		notify  => Service["rng-tools"],
		require => Package["rng-tools"];
	}

	service { "rng-tools":
		ensure  => running,
		pattern => "/usr/sbin/rngd",
		require => File["/etc/default/rng-tools"];
	}
}
