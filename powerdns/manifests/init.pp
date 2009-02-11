# Puppet manifest for PowerDNS
#
# Tested on Debian GNU/Linux 4.0 (etch).
#
# Copyright (c) 2009 by Kees Meijs <kees@kumina.nl> for Kumina bv.
#
# This work is licensed under the Creative Commons Attribution-Share Alike 3.0
# Unported license. In short: you are free to share and to make derivatives of
# this work under the conditions that you appropriately attribute it, and that
# you only distribute it under the same, similar or a compatible license. Any
# of the above conditions can be waived if you get permission from the copyright
# holder.
#
# For information about configuration, please refer to files/README.

class powerdns::common {
	# Make sure directories have correct permissions.
	file {
		"/var/lib/powerdns":
			ensure => directory,
			owner => "root",
			group => "pdns",
			mode => 775,
			require => Package["pdns-server"];
		"/etc/powerdns/pdns.d":
			ensure => directory,
			owner => "root",
			group => "pdns",
			mode => "750",
			require => Package["pdns-server"];
	}

	# Make sure PowerDNS is running.
	service {
		"pdns":
			ensure => running,
			hasrestart => true,
			require => Package["pdns-server"];
	}
}

class powerdns::master inherits powerdns::common {
	# Install needed packages.
        package {
		"pdns-server":
			ensure => installed;
		"pdns-backend-mysql":
			ensure => installed;
	}

	# TODO
	# /etc/powerdns/pdns.conf
}

class powerdns::slave inherits powerdns::common {
	# Install needed packages.
        package {
		"pdns-server":
			ensure => installed;
		"pdns-backend-sqlite":
			ensure => installed;
	}

	# TODO
	# /etc/powerdns/pdns.conf
}

class powerdns::recursor {
	# Install needed packages.
        package {
		"pdns-recursor":
			ensure => installed;
	}

	# Make sure PowerDNS recursor is running.
	service {
		"pdns-recursor":
			ensure => running,
			hasrestart => true,
			require => Package["pdns-recursor"];
	}

	# TODO
	# /etc/powerdns/recursor.conf
}
