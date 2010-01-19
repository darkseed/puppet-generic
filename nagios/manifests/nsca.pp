class nagios::nsca {
	package { "nsca":
		ensure => installed,
	}

	service { "nsca":
		enable => true,
		ensure => running,
		hasrestart => true,
		subscribe => File["/etc/nsca.cfg"],
	}

	file { "/etc/nsca.cfg":
		source => "puppet://puppet/nagios/nsca/nsca.cfg",
		mode => 640,
		owner => "root",
		group => "nagios",
		require => Package["nsca"];
	}
}
