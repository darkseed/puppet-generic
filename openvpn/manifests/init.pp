class openvpn::common {
	package {
		"openvpn":
			ensure => installed,
	}
}

class openvpn::server {
	include openvpn::common

	file {
		"/etc/openvpn/server.conf":
			source => "puppet://puppet/openvpn/server.conf",
			mode => 644,
			owner => "root",
			group => "root",
			require => Package["openvpn"],
	}

	service {
		"openvpn":
			subscribe => File["/etc/openvpn/server.conf"],
			ensure => running,
	}
}

class openvpn::client {
	include openvpn::common

	file {
		"/etc/openvpn/client.conf":
			source => "puppet://puppet/openvpn/client.conf",
			mode => 644,
			owner => "root",
			group => "root",
			require => Package["openvpn"],
	}
}
