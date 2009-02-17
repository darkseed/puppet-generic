class vserver::common {
	# Make sure sshd does not bind to all IP addresses
	file { "/etc/ssh/sshd_config":
		content => template("vserver/ssh/sshd_config"),
		owner => "root",
		group => "root",
		notify => Service["ssh"],
		require => Package["openssh-server"],
	}
}

class vserver::host {
	include vserver::common
	include debian::backports

	package { ["util-vserver", "vserver-debiantools", "libvirt-bin"]:
		ensure => installed,
		require => Apt::Source["${lsbdistcodename}-backports"],
	}

	file { "/srv/vservers":
		ensure => directory,
		owner => "root",
		group => "root",
		mode => "755",
	}

	file { "/etc/vservers/.defaults/vdirbase":
		ensure => link,
		target => "/srv/vservers",
		require => Package["util-vserver"],
	}
}

class vserver::guest {
	include vserver::common
}
