class iaxmodem {
	package {
		"iaxmodem":
			ensure => present;
	}

	service {
		"iaxmodem":
			ensure => running;
	}
}
