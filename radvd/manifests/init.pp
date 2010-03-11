class radvd::server {
	package {
		"radvd":
			ensure => present;
	}

	service {
		"radvd":
			subscribe => File["/etc/radvd.conf"],
			require => File["/etc/radvd.conf"],
			ensure => running;
	}

	file {
		"/etc/radvd.conf":
			require => Package["radvd"],
			owner => "root",
			group => "root",
			mode => 644;
	}
}
