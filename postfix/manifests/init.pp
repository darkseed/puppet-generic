class postfix {
	package { "postfix":
		ensure => installed,
	}

	service { "postfix":
		enable => true,
		hasrestart => true,
		pattern => "/usr/lib/postfix/master",
		require => Package["postfix"],
	}

	file {
		"/etc/postfix/main.cf":
			owner => "root",
			group => "root",
			mode => 644,
			content => template("postfix/main.cf"),
			notify => Service["postfix"];
		"/var/spool/postfix/dovecot":
			ensure => directory,
			owner => "postfix",
			group => "mail",
			mode => 755,
			require => Package["postfix"];
	}

	exec { "newaliases":
		refreshonly => true,
		path => "/usr/bin",
	}
}
