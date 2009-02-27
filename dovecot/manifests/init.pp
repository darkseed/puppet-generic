class dovecot::common {
	package {
		"dovecot-common":
			ensure => installed,
	}

	service {
		"dovecot":
			ensure => running,
			require => Package["dovecot-common"],
	}
}

class dovecot::imap inherits dovecot::common {
	package {
		"dovecot-imapd":
			ensure => installed,
			require => Package["dovecot-common"],
	}
}

class dovecot::pop3 inherits dovecot::common {
	package {
		"dovecot-pop3d":
			ensure => installed,
			require => Package["dovecot-common"],
	}
}
