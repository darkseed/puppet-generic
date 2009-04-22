class zope {
	package { "zope2.9":
		ensure => installed,
		# Set the symlink before the package tries to create
		# /var/lib/zope2.9.
		require => File["/var/lib/zope2.9"],
	}

	package { "zope-common":
		ensure => installed,
	}

	service { "zope2.9":
		ensure => running,
		require => Package["zope2.9"],
	}

	file { "/etc/zope2.9":
		ensure => directory,
		owner => "root",
		group => "root",
		mode => 755,
	}

	file { "/etc/logrotate.d/zope2.9":
		source => "puppet://puppet/zope/logrotate.d/zope2.9",
		owner => "root",
		group => "root",
		mode => 644,
	}

	file { "/etc/cron.weekly/zodb-pack":
		source => "puppet://puppet/zope/cron.weekly/zodb-pack",
		owner => root,
		group => root,
		mode => 755,
	}

	file {
		"/srv/zope2.9":
			ensure => directory,
			mode => 755,
			owner => "root",
			group => "root";
		"/var/run/zope2.9":
			ensure => directory,
			mode => 1777,
			owner => "root",
			group => "root";
		"/var/lock/zope2.9":
			ensure => directory,
			mode => 755,
			owner => "root",
			group => "root";
		"/var/lib/zope2.9":
			ensure => link,
			target => "/srv/zope2.9",
			owner => "root",
			group => "root",
			require => File["/srv/zope2.9"];
	}
}

class zope::server {
	include zope

	file {
		"/srv/zope2.9/instance":
			ensure => directory,
			mode => 755,
			owner => "root",
			group => "root",
			require => File["/srv/zope2.9"];
		"/var/log/zope2.9/instance":
			ensure => directory,
			mode => 755,
			owner => "zope",
			group => "zope",
			require => Package["zope2.9"];
		"/var/run/zope2.9/instance":
			ensure => directory,
			mode => 1777,
			owner => "zope",
			group => "zope",
			require => File["/var/run/zope2.9"];
		"/var/lock/zope2.9/instance":
			ensure => directory,
			mode => 775,
			owner => "zope",
			group => "zope",
			require => File["/var/lock/zope2.9"];
	}

	define instance($port, $ipaddress="127.0.0.1", $zeosocket=false, $products_from=false, $debugmode=false, $zodbcachesize=20000, $user="zope", $group="zope") {
		exec { "start-zope-instance-$name":
			command => "/usr/bin/dzhandle -z 2.9 zopectl $name start",
			refreshonly => true,
			require => [File["/etc/zope2.9/$name/zope.conf"],
			            File["/var/log/zope2.9/instance/$name"],
				    File["/var/run/zope2.9/instance"]]
		}

		exec { "create-zope-instance-$name":
			command => "/usr/bin/dzhandle -u $user:$group -z 2.9 make-instance $name --service-user $user:$group --service-port=$port -m manual -u inituser:changeme",
			creates => "/srv/zope2.9/instance/$name",
			notify => Exec["start-zope-instance-$name"],
			require => [File["/srv/zope2.9/instance"],
			            Package["zope-common"],
				    Package["zope2.9"]],
		}

		file {
			"/var/log/zope2.9/$name":
				ensure => absent,
				force => true,
				owner => $user,
				group => $group,
				mode => 750,
				require => Exec["create-zope-instance-$name"];
			"/var/log/zope2.9/instance/$name":
				ensure => directory,
				owner => $user,
				group => $group,
				mode => 750,
				require => File["/var/log/zope2.9/instance"];
			"/srv/zope2.9/instance/$name":
				ensure => directory,
				owner => $user,
				group => $group,
				mode => 750,
				require => Exec["create-zope-instance-$name"];
			"/srv/zope2.9/instance/$name/log":
				ensure => link,
				target => "/var/log/zope2.9/instance/$name",
				require => [File["/var/log/zope2.9/instance/$name"], Exec["create-zope-instance-$name"]];
			"/srv/zope2.9/instance/$name/import":
				owner => $user,
				group => $group,
				mode => 770,
				require => Exec["create-zope-instance-$name"];
			"/srv/zope2.9/instance/$name/var":
				owner => $user,
				group => $group,
				mode => 770,
				require => Exec["create-zope-instance-$name"];
			"/srv/zope2.9/instance/$name/bin":
				owner => root,
				group => root,
				mode => 755,
				require => Exec["create-zope-instance-$name"];
			"/srv/zope2.9/instance/$name/bin/zopectl":
				owner => root,
				group => root,
				mode => 755,
				content => template("zope/zope/bin/zopectl"),
				require => Exec["create-zope-instance-$name"];
			"/srv/zope2.9/instance/$name/bin/runzope":
				owner => root,
				group => root,
				mode => 755,
				content => template("zope/zope/bin/runzope"),
				require => Exec["create-zope-instance-$name"];
			"/srv/zope2.9/instance/$name/bin/runzope.bat":
				owner => root,
				group => root,
				mode => 644,
				require => Exec["create-zope-instance-$name"];
			"/srv/zope2.9/instance/$name/bin/zopeservice.py":
				owner => root,
				group => root,
				mode => 644,
				require => Exec["create-zope-instance-$name"];
		}

		file {
			"/srv/zope2.9/instance/$name/Products":
				ensure => $products_from ? {
					false   => directory,
					default => "/srv/zope2.9/instance/$products_from/Products",
				},
				force => true,
				owner => $user,
				group => $group,
				mode => 775,
				require => Exec["create-zope-instance-$name"];
			"/srv/zope2.9/instance/$name/Products.custom":
				ensure => $products_from ? {
					false   => directory,
					default => "/srv/zope2.9/instance/$products_from/Products.custom",
				},
				force => true,
				owner => $user,
				group => $group,
				mode => 775,
				require => Exec["create-zope-instance-$name"];
			"/srv/zope2.9/instance/$name/Products.deployer":
				ensure => $products_from ? {
					false   => directory,
					default => "/srv/zope2.9/instance/$products_from/Products.deployer",
				},
				force => true,
				owner => $user,
				group => $group,
				mode => 775,
				require => Exec["create-zope-instance-$name"];
		}

		file { "/etc/zope2.9/$name/zope.conf":
			content => template("zope/zope/zope.conf"),
			require => Exec["create-zope-instance-$name"],
			owner => "root",
			group => "root",
		}
	}
}

class zope::zeo {
	include zope

	file {
		"/srv/zope2.9/zeo":
			ensure => directory,
			mode => 755,
			owner => "root",
			group => "root",
			require => File["/srv/zope2.9"];
		"/var/log/zope2.9/zeo":
			ensure => directory,
			mode => 775,
			owner => "zope",
			group => "zope",
			require => Package["zope2.9"];
		"/var/run/zope2.9/zeo":
			ensure => directory,
			mode => 775,
			owner => "zope",
			group => "zope",
			require => File["/var/run/zope2.9"];
		"/var/lock/zope2.9/zeo":
			ensure => directory,
			mode => 770,
			owner => "zope",
			group => "zope",
			require => File["/var/lock/zope2.9"];

	}

	define instance($socket, $user="zope", $group="zope", $monitor_port=false) {
		exec { "start-zeo-instance-$name":
			command => "/usr/bin/dzhandle -z 2.9 zeoctl $name start",
			refreshonly => true,
			require => [File["/var/log/zope2.9/zeo/$name.log"],
			            File["/srv/zope2.9/zeo/$name/var"],
			            File["/srv/zope2.9/zeo/$name/bin/zeoctl"],
			            File["/srv/zope2.9/zeo/$name/bin/runzeo"],
				    File["/var/run/zope2.9/instance"],
				    File["/etc/zope2.9/$name/zeo.conf"]],
		}

		exec { "create-zeo-instance-$name":
			command => "/usr/bin/dzhandle -z 2.9 make-zeoinstance $name",
			creates => "/srv/zope2.9/zeo/$name",
			require => [File["/srv/zope2.9/zeo"], Package["zope-common"], Package["zope2.9"]],
			notify => Exec["start-zeo-instance-$name"],
		}

		file {
			"/etc/zope2.9/$name":
				ensure => directory,
				mode => 755,
				owner => "root",
				group => "root",
				require => File["/etc/zope2.9"];
			"/etc/zope2.9/$name/zeo.conf":
				mode => 644,
				owner => "root",
				group => "root",
				content => template("zope/zeo/zeo.conf"),
				require => File["/etc/zope2.9/$name"];
		}

		file {
			"/srv/zope2.9/zeo/$name":
				mode => 755,
				owner => $user,
				group => $user,
				require => Exec["create-zeo-instance-$name"];
			"/srv/zope2.9/zeo/$name/bin":
				mode => 755,
				owner => "root",
				group => "root",
				require => Exec["create-zeo-instance-$name"];
			"/srv/zope2.9/zeo/$name/bin/zeoctl":
				mode => 755,
				owner => "root",
				group => "root",
				content => template("zope/zeo/bin/zeoctl"),
				require => Exec["create-zeo-instance-$name"];
			"/srv/zope2.9/zeo/$name/bin/runzeo":
				mode => 755,
				owner => "root",
				group => "root",
				content => template("zope/zeo/bin/runzeo"),
				require => Exec["create-zeo-instance-$name"];
			"/srv/zope2.9/zeo/$name/var":
				ensure => directory,
				mode => 750,
				owner => $user,
				group => $group,
				require => Exec["create-zeo-instance-$name"];
			"/srv/zope2.9/zeo/$name/etc":
				ensure => absent,
				force => true,
				require => Exec["create-zeo-instance-$name"];
			"/srv/zope2.9/zeo/$name/log":
				ensure => absent,
				force => true,
				require => Exec["create-zeo-instance-$name"];
			"/var/log/zope2.9/zeo/$name.log":
				ensure => present,
				mode => 640,
				owner => $user,
				group => $group,
				require => File["/var/log/zope2.9/zeo"];
		}
	}
}
