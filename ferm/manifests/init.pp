class ferm {
	package { "ferm":
		ensure => installed;
	}

	exec { "reload-ferm":
		command     => "/etc/init.d/ferm reload",
		subscribe   => File["/etc/ferm/ferm.conf"],
		refreshonly => true;
	}

	file { "/etc/ferm/ferm.conf":
		ensure  => file,
		mode    => 644,
		owner   => "root",
		group   => "adm",
		require => Package["ferm"];
	}
}
