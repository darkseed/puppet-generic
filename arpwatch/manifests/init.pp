class arpwatch {
	package {
		"arpwatch":
			ensure => present;
	}

	service {
		"arpwatch":
			ensure => running,
			require => File["/etc/default/arpwatch"],
			subscribe => File["/etc/default/arpwatch"];
	}

	file {
		"/etc/default/arpwatch":
			require => Package["arpwatch"],
			owner => "root",
			group => "root",
			mode => 644;
	}
}
