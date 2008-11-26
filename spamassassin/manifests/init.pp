class spamassassin {
	package { "spamassassin":
		ensure => installed,
	}

	file { "/etc/default/spamassassin":
		owner => "root",
		group => "root",
		mode => 644,
		source => "puppet://puppet/spamassassin/default/spamassassin",
	}
}
