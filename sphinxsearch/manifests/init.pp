# Puppet module for Sphinxsearch
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
# This manifest was tested on Debian GNU/Linux 5.0.1 (lenny).

class sphinxsearch::server {
	# Install needed package.
	package {
		"sphinxsearch":
			ensure => present;
	}

	# Run Sphinxsearch searchd daemon.
	service {
		"sphinxsearch":
			ensure => running,
			pattern => "searchd",
			hasstatus => false;
	}
}
