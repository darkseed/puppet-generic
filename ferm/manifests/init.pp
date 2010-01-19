class ferm {
	package {
		"ferm":
			ensure => installed;
	}

	exec { 
		"reload-ferm":
			command => "/usr/sbin/ferm /etc/ferm/ferm.conf",
			subscribe => File["/etc/ferm/ferm.conf"],
			refreshonly => true;
	}

	file {
		"/etc/ferm/ferm.conf":
			mode => 644,
			owner => "root",
			group => "adm",
			require => Package["ferm"];
	}
}
