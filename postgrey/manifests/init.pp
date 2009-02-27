class postgrey {
	package { "postgrey":
		ensure => installed,
	}

	service { "postgrey":
		enable => true,
	}
}
