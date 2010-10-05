class apt {
	define source($sourcetype="deb", $uri, $distribution="stable", $components=[], $comment="", $ensure="file") {
		file { "/etc/apt/sources.list.d/$name.list":
			ensure => $ensure,
			owner => "root",
			group => "root",
			mode => 644,
			content => template("apt/source.list"),
			require => File["/etc/apt/sources.list.d"],
		}
	}

	define key($ensure = 'present') {
		case $ensure {
			default: {
				err("unknown ensure value ${ensure}")
			}
			present: {
				exec { "/usr/bin/wget -qq -O - 'http://keys.gnupg.net:11371/pks/lookup?op=get&search=0x$name' | /usr/bin/apt-key add -":
					unless => "/usr/bin/apt-key list | grep -q $name",
					require => Package["wget"],
					notify => Exec["/usr/bin/apt-get update"];
				}
			}
			absent: {
				exec { "/usr/bin/apt-key del $name":
					onlyif => "/usr/bin/apt-key list | grep -q $name",
				}
			}
		}
	}

	package { "wget":
		ensure => installed,
	}

	file {
		# Putting files in a directory is much easier to manage with
		# Puppet than modifying /etc/apt/sources.lists.
		"/etc/apt/sources.list":
			ensure => absent,
			notify => Exec["/usr/bin/apt-get update"];
		"/etc/apt/sources.list.d":
			ensure => directory,
			owner => "root",
			group => "root",
			mode => 755,
			recurse => false,
			notify => Exec["/usr/bin/apt-get update"];
	}

	# Increase the available cachesize
	file { "/etc/apt/apt.conf.d/50cachesize":
		ensure => file,
		content => "APT::Cache-Limit \"33554432\";\n",
		notify => Exec["/usr/bin/apt-get update"];
	}

	# Run apt-get update when anything beneath /etc/apt/sources.list.d changes
	exec { "/usr/bin/apt-get update":
		refreshonly => true,
	}
}
