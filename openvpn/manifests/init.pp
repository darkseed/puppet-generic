class openvpn::common {
	package { "openvpn":
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
			require => [Package["openvpn"], File["/var/lib/openvpn"]];
		"/var/lib/openvpn":
			ensure => "directory",
			owner => "root",
			group => "root",
			mode => 750;
	}

	service { "openvpn":
		subscribe => File["/etc/openvpn/server.conf"],
		ensure => running,
	}

}

class openvpn::client {
	include openvpn::common

	file { "/etc/openvpn/client.conf":
		source => "puppet://puppet/openvpn/client.conf",
		mode => 644,
		owner => "root",
		group => "root",
		require => Package["openvpn"],
	}
}
