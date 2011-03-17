class icinga::server {
        package {
		"icinga":
                	ensure => installed;
		"icinga-doc":
			ensure => installed;
        }

        exec { "reload-icinga":
                command     => "/etc/init.d/icinga reload",
                refreshonly => true,
        }
}
