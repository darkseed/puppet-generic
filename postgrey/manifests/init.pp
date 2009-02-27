class postgrey {
	package { "postgrey":
		ensure => installed;
	}

	service { "postgrey":
		require => Package["postgrey"],
		enable => true;
	}
}
