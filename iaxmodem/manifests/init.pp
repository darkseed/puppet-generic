class iaxmodem {
	package {
		"iaxmodem":
			ensure => present;
	}

	service {
		"iaxmodem":
			require => Package["iaxmodem"],
			ensure => running;
	}
}
