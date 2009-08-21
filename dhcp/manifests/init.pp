class dhcp::server {
	package { "dhcp3-server":
		ensure => installed,
	}

	service { "dhcp3-server":
		subscribe => File["/etc/dhcp3/dhcpd.conf"],
		hasrestart => true,
		hasstatus => true,
	}

	file { "/etc/dhcp3/dhcpd.conf":
		source => "puppet://puppet/dhcp/server/dhcpd.conf",
		owner => "root",
		group => "root",
		mode => 644,
	}
}
