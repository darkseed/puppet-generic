class munin::client {
	define plugin($ensure='present', $script_path='/usr/share/munin/plugins', $script=false) {
		if $script {
			$plugin_path = "$script_path/$script"
		} else {
			$plugin_path = "$script_path/$name"
		}

		file { "/etc/munin/plugins/$name":
			ensure => $ensure ? {
				'present' => $plugin_path,
				'absent' => 'absent',
			},
			notify => Service["munin-node"],
			require => [Package["munin-node"], File["/usr/local/share/munin/plugins"]],
		}
	}

	define plugin::config($content, $section=false, $ensure='present') {
		file { "/etc/munin/plugin-conf.d/$name":
			ensure => $ensure,
			owner => "root",
			group => "root",
			mode => 644,
			content => $section ? {
				false => "[${name}]\n${content}\n",
				default => "[${section}]\n${content}\n",
			},
			require => Package["munin-node"],
			notify => Service["munin-node"],
		}
	}

	package { "munin-node":
		ensure => installed,
	}

	if (($operatingsystem == "Debian") and (versioncmp($lsbdistrelease,"5.0") >= 0)) { # in Lenny and above we have the extra-plugins in a package
		package { "munin-plugins-extra":
			ensure => latest,
		}
	}
	
	# Extra plugins
	file { "/usr/local/share/munin/plugins":
		recurse => true,
		source => "puppet://puppet/munin/client/plugins",
		owner => "root",
		group => "staff",
		mode => 755,
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


	# Configs needed for JMX monitoring. Not needed everywhere, but roll out
	# nontheless.
	file { "/usr/local/etc/munin/plugins":
		recurse => true,
		source  => "puppet:///modules/munin/client/configs",
		owner   => "root",
		group   => "staff",
		mode    => 755;
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
