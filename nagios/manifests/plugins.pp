class nagios::plugins {
	kpackage { "nagios-plugins-basic":
		ensure => installed;
	}

	kfile {
		"/usr/local/lib/nagios":
			ensure => directory,
			group  => "staff",
			mode   => 2775;
		"/usr/local/lib/nagios/plugins":
			ensure => directory,
			group  => "staff";
	}
}
