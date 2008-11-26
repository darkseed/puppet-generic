class clamav {
	package { ["clamav-daemon", "clamav-freshclam"]:
		ensure => installed,
	}

	service { "clamav-daemon":
		enable => true,
		pattern => "/usr/sbin/clamd",
		require => Package["clamav-daemon"],
	}

	service { "clamav-freshclam":
		enable => true,
		pattern => "/usr/bin/freshclam",
		require => Package["clamav-freshclam"],
	}
}
