class spamassassin {
	package { "spamassassin":
		ensure => installed,
	}

	package { ["libmail-spf-perl", "libmail-dkim-perl"]:
		ensure => installed,
	}

	file { "/etc/default/spamassassin":
		owner => "root",
		group => "root",
		mode => 644,
		source => "puppet://puppet/spamassassin/default/spamassassin",
	}
}
