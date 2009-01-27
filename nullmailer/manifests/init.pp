class nullmailer {
	package { ["nullmailer"]:
		ensure => installed,
	}

	package { ["postfix", "exim4", "exim4-daemon-light", "exim4-base", "exim4-config"]:
		ensure => absent,
	}

	file {
		"/etc/nullmailer/adminaddr":
			content => "$mail_catchall\n",
			require => Package["nullmailer"];
		"/etc/nullmailer/remotes":
			content => "$mail_relay\n",
			require => Package["nullmailer"];
		"/etc/mailname":
			content => "$fqdn\n",
			require => Package["nullmailer"];
	}
}
