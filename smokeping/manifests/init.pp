class smokeping {
	package { "smokeping":
		ensure => installed,
	}

	service { "smokeping":
		ensure => running,
		require => Package["smokeping"],
		hasrestart => true,
	}

	file { "/etc/smokeping/config":
		source => "puppet://puppet/smokeping/config",
		owner => "root",
		group => "root",
		mode => 644,
		notify => Service["smokeping"],
	}
}
