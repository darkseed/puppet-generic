class openssl::common {
	package { "openssl":
		ensure => installed,
	}

	file {
		"/etc/ssl/certs":
			require => Package["openssl"],
			checksum => "md5",
			recurse => true;
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
		"/etc/ssl/Makefile":
			source => "puppet:///modules/openssl/Makefile",
			mode => 644,
			owner => "root",
			group => "root",
			require => Package["openssl"];
	}
}
