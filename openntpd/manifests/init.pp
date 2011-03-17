class openntpd::common {
	package { "openntpd":
                ensure => installed,
        }

	service { "openntpd":
		hasrestart => true,
		ensure => running,
		pattern => "/usr/sbin/ntpd",
		require => Package["openntpd"],
	}
}
