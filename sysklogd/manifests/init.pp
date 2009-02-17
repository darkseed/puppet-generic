class sysklogd::common {
	package { "sysklogd":
		ensure => installed,
	}

	service { "sysklogd":
		subscribe => File["/etc/syslog.conf"],
		ensure => running,
		pattern => "/sbin/syslogd",
	}
}

class sysklogd::client {
	include sysklogd::common

	file { "/etc/syslog.conf":
		content => template("sysklogd/client/syslog.conf"),
		require => Package["sysklogd"],
		owner => "root",
		group => "root",
	}
}

class sysklogd::server {
	include sysklogd::common

	file { "/etc/default/syslogd":
		source => "puppet://puppet/sysklogd/server/default/syslogd",
		require => Package["sysklogd"],
		owner => "root",
		group => "root",
	}
}
