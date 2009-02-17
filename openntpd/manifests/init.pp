class openntpd::common {
	package { "openntpd":
                ensure => installed,
        }

	service { "openntpd":
		hasrestart => true,
		subscribe => File["/etc/openntpd/ntpd.conf"],
		ensure => running,
		pattern => "/usr/sbin/ntpd",
		require => Package["openntpd"],
	}
}

class openntpd::client {
	include openntpd::common

        file { "/etc/openntpd/ntpd.conf":
                source => "puppet://puppet/openntpd/client/ntpd.conf",
		owner => "root",
		group => "root",
		require => Package["openntpd"],
        }
}

class openntpd::server {
	include openntpd::common

	file { "/etc/openntpd/ntpd.conf":
		source => "puppet://puppet/openntpd/server/ntpd.conf",
		owner => "root",
		group => "root",
		require => Package["openntpd"],
	}
}
