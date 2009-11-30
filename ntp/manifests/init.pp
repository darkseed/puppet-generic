class ntp {
	package { "ntp":
		ensure => installed,
	}

	file { "/etc/ntp.conf":
		source  => "puppet://puppet/ntp/ntp.conf",
		owner   => "root",
		group   => "root",
		require => Package["ntp"],
	}

	service { "ntp":
		hasrestart => true,
		hasstatus  => true,
		ensure 	   => running,
	}
}

