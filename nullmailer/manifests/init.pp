class nullmailer {
	package {
		"nullmailer":
			ensure => present;
	}

	service {
		"nullmailer":
			require => Package["nullmailer"],
			ensure => running;
	}

	package {
		"postfix":
			ensure => absent;
		"exim4":
			ensure => absent;
		"exim4-daemon-light":
			ensure => absent;
		"exim4-base":
			ensure => absent;
		"exim4-config":
			ensure => absent;
	}

	file {
		"/etc/nullmailer/adminaddr":
			content => "$mail_catchall\n",
			notify => Service["nullmailer"],
			require => Package["nullmailer"];
		"/etc/nullmailer/remotes":
			content => "$mail_relay\n",
			notify => Service["nullmailer"],
			require => Package["nullmailer"];
		"/etc/mailname":
			content => "$fqdn\n",
			notify => Service["nullmailer"],
			require => Package["nullmailer"];
	}
}
