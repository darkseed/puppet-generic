class hylafax::server {
	package {
		"hylafax-server":
			ensure => present;
	}

	service {
		"hylafax":
			require => Package["hylafax-server"],
			pattern => "hfaxd",
			ensure => running;
	}
}
