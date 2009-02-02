class munin::client {
	package { "munin-node":
		ensure => installed,
	}

	if (($operatingsystem == "Debian") and ($operatingsystemrelease == "5.0")) {
		package { "munin-plugins-extra":
			ensure => installed,
		}
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
		mode => 755,
	}
}

class munin::server {
	package { ["munin"]:
		ensure => installed,
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
		owner = > "root",
		group => "munin",
		require => Package["nsca"],
	}

        # Needed when munin-graph runs as a CGI script
	package { "libdate-manip-perl":
		ensure => installed,
	}

	file {
		"/var/log/munin":
			owner => "munin",
			group => "adm",
			mode => 751;
		"/var/log/munin/munin-graph.log":
			group => "www-data",
			mode => 660;
		"/etc/logrotate.d/munin":
			owner => "root",
			group => "root",
			mode => 644,
			source => "puppet://puppet/munin/server/logrotate.d/munin";
	}
}
