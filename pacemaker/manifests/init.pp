# Copyright (C) 2010 Kumina bv, Ed Schouten <ed@kumina.nl>
# This works is published under the Creative Commons Attribution-Share 
# Alike 3.0 Unported license - http://creativecommons.org/licenses/by-sa/3.0/
# See LICENSE for the full legal text.

class pacemaker {
	file { "/usr/lib/ocf/resource.d/kumina":
		ensure => directory,
		owner => "root",
		group => "root",
		mode => 755,
		require => Package["pacemaker"];
	}

	file { "/usr/lib/ocf/resource.d/kumina/update-dns":
		source => "puppet:///pacemaker/update-dns",
		owner => "root",
		group => "root",
		mode => 755,
		require => File["/usr/lib/ocf/resource.d/kumina"];
	}

	define updatednsconfig($ipme, $ipother) {
		file { "${name}":
			content => template("pacemaker/update-dns"),
			owner => "root",
			group => "root",
			mode => 644;
		}
	}
}
