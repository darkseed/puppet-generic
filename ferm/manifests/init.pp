class ferm {
	package {
		"ferm":
			ensure => installed;
	}

	service { 
		"ferm":
			subscribe => File["/etc/ferm/ferm.conf"],
			require => Package["ferm"];
	}

	file {
		"/etc/ferm/ferm.conf":
			mode => 644,
			owner => "root",
			group => "adm",
			require => Package["ferm"];
	}
}
