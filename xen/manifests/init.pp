class xen::dom0 {
	include "xen::dom0::$lsbdistcodename"

	# Architecture independent packages
	package { ["xen-utils-common", "xen-tools", "bridge-utils"]:
		ensure => installed,
	}

	# CHECK IF THIS IS COMPATIBLE WITH LENNY
	file { "/etc/default/xendomains":
		source => "puppet://puppet/xen/dom0/default/xendomains",
		owner => "root",
		group => "root",
		mode => 644,
		require => Package["xen-utils-common"];
	}

	# OTHER XEN CONFIGURATION?

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

class xen::dom0::etch {
	$archdependent = $architecture ? {
		i386  => ["xen-hypervisor-3.0.3-1-i386-pae", "linux-image-2.6-xen-686"],
		amd64 => ["xen-hypervisor-3.0.3-1-amd64", "linux-image-2.6-xen-amd64"],
	}
	
	# Architecture dependent packages
	package { $archdependent:
		ensure => installed,
	}
}

class xen::dom0::lenny {
	$archdependent = $architecture ? {
		i386  => ["xen-hypervisor-3.2-1-i386", "linux-image-2.6-xen-686"],
		amd64 => ["xen-hypervisor-3.2-1-amd64", "linux-image-2.6-xen-amd64"],
	}
	
	# Architecture dependent packages
	package { $archdependent:
		ensure => installed,
	}
}
