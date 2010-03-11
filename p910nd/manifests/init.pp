class p910nd::server {
	package {
		"p910nd":
			ensure => present;
	}

	service {
		"p910nd":
			ensure => running,
			require => File["/etc/default/p910nd"],
			subscribe => File["/etc/default/p910nd"];
	}

	file {
		"/etc/default/p910nd":
			require => Package["p910nd"],
			owner => "root",
			group => "root",
			mode => 644;
	}
}
