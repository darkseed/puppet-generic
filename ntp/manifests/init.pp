class ntp::client {
	package { "ntp":
                ensure => installed,
        }

        file { "/etc/ntp.conf":
                source => "puppet://puppet/ntp/client/ntp.conf",
		owner => "root",
		group => "root",
		require => Package["ntp"],
        }

        service { "ntp":
                hasrestart => true,
                hasstatus => true,
                subscribe => File["/etc/ntp.conf"],
                ensure => running,
        }
}

class ntp::server {
	package { "openntpd":
		ensure => installed,
	}

	file {
		"/etc/openntpd/ntpd.conf":
			owner => "root",
			group => "root",
			source => "puppet://puppet/ntp/server/openntpd/ntpd.conf",
			require => Package["openntpd"];
#		"/etc/sysctl.conf":
#			owner => "root",
#			group => "root",
#			source => "puppet://puppet/ntp/server/sysctl.conf";
	}

	service { "openntpd":
		hasrestart => true,
		subscribe => File["/etc/openntpd/ntpd.conf"],
		ensure => running,
		pattern => "/usr/sbin/ntpd",
	}
}
