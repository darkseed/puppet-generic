class avahi::daemon {
	package {
		"avahi-daemon":
			ensure => present;
	}

	service {
		"avahi-daemon":
			ensure => running,
			require => File["/etc/avahi/avahi-daemon.conf"],
			subscribe => File["/etc/avahi/avahi-daemon.conf"];
	}

	file {
		"/etc/avahi/avahi-daemon.conf":
			require => Package["avahi-daemon"],
			owner => "root",
			group => "root",
			mode => 644;
	}
}
