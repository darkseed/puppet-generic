class ntp {
	kpackage { "ntp":
		ensure => latest;
	}

	service { "ntp":
		hasrestart => true,
		hasstatus  => true,
		ensure 	   => running,
		require    => Package["ntp"];
	}
}

