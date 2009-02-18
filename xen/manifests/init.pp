class xen::dom0 {
	# Architecture independent packages
	package { ["xen-utils-common", "xen-tools", "bridge-utils"]:
		ensure => installed,
	}

	# Architecture dependent packages
	$archdependent = $architecture ? {
		i386  => ["xen-hypervisor-3.0.3-1-i386-pae", "linux-image-2.6-xen-686"],
		amd64 => ["xen-hypervisor-3.0.3-1-amd64", "linux-image-2.6-xen-amd64"],
	}

	package { $archdependent:
		ensure => installed,
	}

	file { "/etc/default/xendomains":
		source => "puppet://puppet/xen/dom0/default/xendomains",
		owner => "root",
		group => "root",
		mode => 644,
		require => Package["xen-utils-common"];
	}

	# Create directories (missing by default)
	file {
		"/etc/xen/auto":
			ensure => directory,
			owner => "root",
			group => "root",
			mode => 755,
			require => Package["xen-utils-common"];
		"/etc/xen/domains":
			ensure => directory,
			owner => "root",
			group => "root",
			mode => 755,
			require => Package["xen-utils-common"];
	}
}
