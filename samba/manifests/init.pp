class samba::common {
	package {
		"samba-common":
			ensure => installed;
	}
}

class samba::server {
	include samba::common

	package {
		"samba":
			require => Package["samba-common"],
			ensure => installed;
	}

	service {
		"samba":
			subscribe => File["/etc/samba/smb.conf"],
			pattern => "smbd",
			ensure => running;
			# TODO: FIX STATUS (Using Tim's patch?)
	}

	file {
		"/etc/samba/smb.conf":
			source => "puppet://puppet/samba/samba/smb.conf",
			mode => 644,
			owner => "root",
			group => "root",
			require => Package["samba"];
	}
}
