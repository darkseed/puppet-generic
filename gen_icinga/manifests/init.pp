class gen_icinga::server {
	kpackage { ["icinga","icinga-doc"]:; }

	service { "icinga":
#		ensure     => running,
		hasrestart => true,
		hasstatus  => true,
		require    => Package["icinga"];
	}
	
	exec { "reload-icinga":
		command     => "/etc/init.d/icinga reload",
		refreshonly => true;
	}
}
