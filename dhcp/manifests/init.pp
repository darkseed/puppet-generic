class dhcp::server {
	if versioncmp($lsbdistrelease, "6.0") < 0 {
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
	if versioncmp($lsbdistrelease, "6.0") >= 0 {
		package { "isc-dhcp-server":
			ensure => installed,
		}

		service { "isc-dhcp-server":
			subscribe => File["/etc/dhcp/dhcpd.conf"],
			hasrestart => true,
			hasstatus => true,
		}

		file { "/etc/dhcp/dhcpd.conf":
			source => "puppet://puppet/dhcp/server/dhcpd.conf",
			owner => "root",
			group => "root",
			mode => 644,
		}
	}
}
