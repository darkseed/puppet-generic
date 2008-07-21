class munin::client {
	package { ["munin-node"]:
		ensure => installed,
	}

	# Munin node configuration
	file { "/etc/munin/munin-node.conf":
		content => template("munin/client/munin-node.conf"),
		require => Package["munin-node"],
	}

	service { "munin-node":
		subscribe => File["/etc/munin/munin-node.conf"],
		require => [Package["munin-node"], File["/etc/munin/munin-node.conf"]],
		hasrestart => true,
		ensure => running,
	}

	file { "/usr/local/share/munin":
		ensure => directory,
		owner => "root",
		group => "staff",
	}

	file { "/usr/local/etc/munin":
		ensure => directory,
		owner => "root",
		group => "staff",
	}

	# Extra plugins
	file { "/usr/local/share/munin/plugins":
		recurse => true,
		source => "puppet://puppet/munin/client/plugins",
		owner => "root",
		group => "staff",
	}
}

class munin::server {
	package { ["munin", "nsca"]:
		ensure => installed,
	}

	service { "nsca":
		enable => false,
		ensure => running,
		require => Package["nsca"],
	}

	file { "/etc/munin/munin.conf":
		source => "puppet://puppet/munin/server/munin.conf",
		owner => "root",
		group => "root",
		require => Package["munin"],
	}

	file { "/etc/send_nsca.cfg":
		source => "puppet://puppet/munin/server/send_nsca.cfg",
		mode => 640,
		group => "munin",
		require => Package["nsca"],
	}
}
