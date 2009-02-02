class nagios::plugins {
	package { "nagios-plugins-basic":
		ensure => installed,
	}

	file {
		"/usr/local/lib/nagios":
			ensure => directory,
			owner => "root",
			group => "staff",
			mode => 2775;
		"/usr/local/lib/nagios/plugins":
			ensure => directory,
			owner => "root",
			group => "staff",
			mode => 755,
			require => File["/usr/local/lib/nagios"];
	}
}
