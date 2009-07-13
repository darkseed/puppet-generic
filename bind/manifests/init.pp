class bind {
	package { "bind9":
		ensure => installed,
	}

	file {
		"/etc/bind/named.conf.options":
			source => "puppet://puppet/bind/named.conf.options",
			owner => root,
			group => root,
			require => Package["bind9"];
		"/etc/bind/named.conf.local":
			source => "puppet://puppet/bind/named.conf.local",
			owner => root,
			group => root,
			require => Package["bind9"];
		"/etc/bind/zones":
			ensure => directory,
			require => Package["bind9"];
		"/etc/bind/create_zones_conf":
			source => "puppet://puppet/bind/create_zones_conf",
			owner => root,
			group => root,
			mode => 755,
			require => Package["bind9"];
		"/etc/bind/Makefile":
			source => "puppet://puppet/bind/Makefile",
			owner => root,
			group => root,
			require => Package["bind9"];
	}

	service { "bind9":
		ensure => running,
		pattern => "/usr/sbin/named",
		subscribe => [File["/etc/bind/named.conf.local"],
		              File["/etc/bind/named.conf.options"],
			      Exec["update-zone-conf"]],
	}

	exec { "update-zone-conf":
		command => "/bin/sh -c 'cd /etc/bind && make'",
		refreshonly => true,
		require => [File["/etc/bind/zones"],
		            File["/etc/bind/create_zones_conf"],
			    File["/etc/bind/Makefile"],
			    Package["make"]],
	}

	define zone_alias ($target) {
		file { "/etc/bind/zones/$name":
			ensure => link,
			target => "/etc/bind/zones/$target",
			notify => Exec["update-zone-conf"],
			require => File["/etc/bind/zones/$target"],
		}
	}

	define zone ($source, $aliases=false) {
		file { "/etc/bind/zones/$name":
			owner => root,
			group => root,
			source => $source,
			notify => Exec["update-zone-conf"],
		}

		if $aliases {
			zone_alias { $aliases:
				target => $name,
			}
		}
	}
}
