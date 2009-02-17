class rsyslog::common {
	package { "rsyslog":
		ensure => installed,
	}

	service { "rsyslog":
		enable => true,
		require => Package["rsyslog"],
	}
}

class rsyslog::client {
	include rsyslog::common

	file { "/etc/rsyslog.d/remote-logging-client.conf":
		content => template("rsyslog/client/remote-logging-client.conf"),
		owner => "root",
		group => "root",
		mode => 644,
		require => Package["rsyslog"],
		notify => Service["rsyslog"],
	}
}

class rsyslog::server {
	include rsyslog::common

	file { "/etc/rsyslog.d/remote-logging-server.conf":
		source => "puppet://puppet/rsyslog/server/remote-logging-server.conf",
		owner => "root",
		group => "root",
		mode => 644,
		require => Package["rsyslog"],
		notify => Service["rsyslog"],
	}
}
