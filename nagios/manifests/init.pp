class nagios {
	package { ["nagios2", "nagios-plugins"]:
		ensure => installed,
	}

	service { "nagios2":
		ensure => running,
		require => Package["nagios2"],
	}

	# Allow external commands to be submitted through the web interface
	file {
		"/var/lib/nagios2":
			mode => 710,
			group => "www-data";
		"/var/lib/nagios2/rw":
			group => "www-data",
			mode => 2710;
	}
}
