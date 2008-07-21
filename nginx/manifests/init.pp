class nginx {
	package { "nginx":
		ensure => installed,
	}

	service { "nginx":
		ensure => running,
		hasrestart => true,
		require => Package["nginx"],
	}

	file { "/etc/nginx/vhost-additions":
		ensure => directory,
		owner => "root",
		group => "root",
		mode => 755,
		require => Package["nginx"],
	}

	file { "/etc/nginx/sites-enabled":
		ensure => directory,
		owner => "root",
		group => "root",
		mode => 755,
		require => Package["nginx"],
	}

	file { "/etc/nginx/sites-available":
		ensure => directory,
		owner => "root",
		group => "root",
		mode => 755,
		require => Package["nginx"],
	}

	file { "/etc/nginx/conf.d":
		ensure => directory,
		owner => "root",
		group => "root",
		mode => 755,
		require => Package["nginx"],
	}

	file { "/etc/nginx/nginx.conf":
		content => template("nginx/nginx.conf.erb"),
		owner => "root",
		group => "root",
		mode => 644,
	}

	define site_config ($ipaddress = $ipaddress, $serveralias = false, $source = false,
		            $documentroot = "/var/www", $content = false) {
		$domain = $name

		if $source {
			file { "/etc/nginx/sites-available/$name":
				ensure => file,
				owner => "root",
				group => "root",
				mode => 644,
				backup => false,
				source => $source,
				notify => Service["nginx"],
				require => [Package["nginx"],
					    File["/etc/nginx/vhost-additions/$name"],
					    File["/etc/nginx/sites-available"]],
			}
		} else {
			file { "/etc/nginx/sites-available/$name":
				ensure => file,
				owner => "root",
				group => "root",
				mode => 644,
				backup => false,
				content => $content ? {
					false => template("nginx/simple.erb"),
					default => $content,
				},
				notify => Service["nginx"],
				require => [Package["nginx"],
					    File["/etc/nginx/vhost-additions/$name"],
					    File["/etc/nginx/sites-available"]],
			}
		}

		file { "/etc/nginx/vhost-additions/$name":
			ensure => directory,
			owner => "root",
			group => "root",
			mode => 755,
			require => File["/etc/nginx/vhost-additions"],
		}
	}

	define site ($ensure = 'present') {
		file { "/etc/nginx/sites-enabled/$name":
			ensure => $ensure ? {
				'present' => "/etc/nginx/sites-available/$name",
				'absent'  => absent,
			},
			owner => root,
			group => root,
			mode => 644,
			notify => Service["nginx"],
			require => Site_config["$name"],
		}
	}
}
