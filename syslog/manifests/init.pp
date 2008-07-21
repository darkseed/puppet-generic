class syslog::client {
	package { "sysklogd":
		ensure => installed,
	}

	file { "/etc/syslog.conf":
		source => "puppet://puppet/syslog/client/syslog.conf",
		require => Package["sysklogd"],
		owner => "root",
		group => "root",
	}

	service { "sysklogd":
		subscribe => File["/etc/syslog.conf"],
		ensure => running,
		pattern => "/sbin/syslogd",
	}
}

class syslog::server {
	package { "syslog-ng":
		ensure => installed,
	}

	file {
		"/etc/syslog-ng/syslog-ng.conf":
			source => "puppet://puppet/syslog/server/syslog-ng.conf",
			owner => "root",
			group => "root",
			require => Package["syslog-ng"];
		"/etc/logrotate.d/syslog-ng":
			source => "puppet://puppet/syslog/server/logrotate.d/syslog-ng",
			owner => "root",
			group => "root";
	}

	service { "syslog-ng":
		subscribe => File["/etc/syslog-ng/syslog-ng.conf"],
		ensure => running,
	}
}
