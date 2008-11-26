class amavisd-new {
	package { "amavisd-new":
		ensure => installed,
	}

	service { "amavis":
		enable => true,
		ensure => running,
		hasrestart => true,
		require => Package["amavisd-new"],
	}

	file { "/etc/amavis/conf.d/50-user":
		owner => "root",
		group => "root",
		mode => 644,
		source => "puppet://puppet/amavisd-new/conf.d/50-user",
		notify => Service["amavis"],
	}
}
