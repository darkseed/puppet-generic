class ntp {
	package { "ntp":
		ensure => installed,
	}

	file { "/etc/ntp.conf":
		owner   => "root",
		group   => "root",
		mode    => 644,
		require => Package["ntp"],
                checksum => "md5",
	}

	service { "ntp":
		hasrestart => true,
		hasstatus  => true,
		ensure 	   => running,
	}
}

