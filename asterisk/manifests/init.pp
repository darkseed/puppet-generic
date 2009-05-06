class asterisk::server {
	package {
		"asterisk":
			ensure => present;
		"asterisk-sounds-extra":
			ensure => present;
	}
}

class asterisk::zaptel-module-xen {
	$archdependent = $architecture ? {
		i386  => "zaptel-modules-2.6.26-2-xen-686",
		amd64 => "zaptel-modules-2.6.26-2-xen-amd64",
	}

	# Architecture dependent packages.
	package {
		$archdependent:
			require => Package["asterisk"],
			ensure => present;
	}
}
