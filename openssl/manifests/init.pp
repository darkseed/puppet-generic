class openssl::common {
	package { ["openssl"]:
		ensure => installed,
	}

	file { "/etc/ssl/Makefile":
		source => "puppet://puppet/openssl/Makefile",
		mode => 644,
		owner => "root",
		group => "root",
		require => Package["openssl"];
	}
}

class openssl::server {
	include openssl::common

}

class openssl::ca {
	include openssl::common

	file {
		"/etc/ssl/newcerts":
			ensure => directory,
			mode => 750,
			owner => "root",
			group => "root",
			require => Package["openssl"];
		"/etc/ssl/requests":
			ensure => directory,
			mode => 750,
			owner => "root",
			group => "root",
			require => Package["openssl"];
	}
}
