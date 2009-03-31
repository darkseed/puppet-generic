class samba::common {
	package {
		"samba":
			ensure => installed;
	}
}

class samba::server {
	include samba::common

	service {
		"samba":
			subscribe => File["/etc/samba/smb.conf"],
			ensure => running;
			# TODO: FIX STATUS (Using Tim's patch?)
	}

	file {
		"/etc/samba/smb.conf":
			source => "puppet://puppet/samba/smb.conf",
			mode => 644,
			owner => "root",
			group => "root",
			require => Package["samba"];
	}
}
