# Copyright (C) 2010 Kumina bv, Tim Stoop <tim@kumina.nl>
# This works is published under the Creative Commons Attribution-Share 
# Alike 3.0 Unported license - http://creativecommons.org/licenses/by-sa/3.0/
# See LICENSE for the full legal text.

class hetzner {
}

class hetzner::failover_ip {
	package { "python-simplejson":
		ensure => latest,
	}

	file { "/usr/local/sbin/parse-hetzner-json.py":
		source => "puppet:///modules/hetzner/parse-hetzner-json.py",
		owner  => "root",
		group  => "root",
		mode   => 755,
	}

	file { "/usr/local/lib/hetzner":
		ensure => directory,
	}

	file { "/usr/local/lib/hetzner/hetzner-failover-ip":
		source => "puppet:///modules/hetzner/hetzner-failover-ip",
		owner  => "root",
		group  => "root",
		mode   => 755,
	}

}
