class smokeping {
	package { "smokeping":
		ensure => installed,
	}

	service { "smokeping":
		ensure => running,
		require => Package["smokeping"],
		hasrestart => true,
	}

	file {
		"/etc/smokeping/config.d":
			source => "puppet://puppet/smokeping/config.d",
			owner => "root",
			group => "root",
			recurse => true,
			notify => Service["smokeping"];
		"/etc/smokeping/basepage.html":
			source => "puppet://puppet/smokeping/basepage.html",
			mode => 644,
			owner => "root",
			group => "root",
			notify => Service["smokeping"];
		"/etc/smokeping/smokemail":
			source => "puppet://puppet/smokeping/smokemail",
			mode => 644,
			owner => "root",
			group => "root",
			notify => Service["smokeping"];
		"/etc/smokeping/tmail":
			source => "puppet://puppet/smokeping/tmail",
			mode => 644,
			owner => "root",
			group => "root",
			require => Package["smokeping"];
	}
}
