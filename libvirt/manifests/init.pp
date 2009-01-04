class libvirt {
	package { "libvirt-bin":
		ensure => installed,
	}

	service { "libvirt-bin":
		hasrestart => true,
		hasstatus => true,
		require => Package["libvirt-bin"],
	}

	file {
		"/etc/default/libvirt-bin":
			source => "puppet://puppet/libvirt/default/libvirt-bin",
			owner => "root",
			group => "root",
			mode => 644,
			notify => Service["libvirt-bin"];
		"/etc/libvirt/libvirtd.conf":
			content => "puppet://puppet/libvirt/libvirt/libvirtd.conf",
			owner => "root",
			group => "root",
			mode => 644,
			require => Package["libvirt-bin"],
			notify => Service["libvirt-bin"];
	}
}
