import "*.pp"

class tomcat {
	define instance($ensure="running",
                        $user="tomcat55", $group="root",
                        $heap_size="256M",
			$permgen_size="128M",
                        $shutdown_port="8005",
                        $session_replication_port="8006",
                        $ajp13_connector_port="8009",
                        $http_connector_port="8180",
                        $jmx_port="8016",
                        $remote_debugging_port="8012",
	                $clustering=false,
                        $remote_debugging=false,
			$session_replication_mcast_addr=auto,
			$session_replication_mcast_port=45564,
			$session_replication_mcast_domain=false,
		        $extra_java_opts=false) {

		# Add the project to the list of instances, so tomcat5.5.wrap
		# knows it needs to start it. Unless of course we want this
		# instance stopped. In the latter case, we remove it from the
		# list, so it won't start after a reboot.
		case $ensure {
			"running": {
				line { "tomcat-instances-line-${name}":
					file => "/etc/tomcat5.5/instances",
					line => $name,
					require => Package["tomcat5.5"],
				}
			}
			"stopped": {
				line { "tomcat-instances-line-${name}":
					file => "/etc/tomcat5.5/instances",
					line => $name,
					ensure => "absent",
					require => Package["tomcat5.5"],
				}
			}
			default: { err ("Unknown ensure value: '$ensure'") }
		}

		file {
			"/srv/tomcat/$name":
				ensure => directory,
				owner => $user,
				group => $group,
				mode => 750;
			[ "/srv/tomcat/$name/conf",
			  "/srv/tomcat/$name/logs",
			  "/srv/tomcat/$name/temp",
			  "/srv/tomcat/$name/work",
			  "/srv/tomcat/$name/webapps",
			  "/srv/tomcat/$name/shared",
			  "/srv/tomcat/$name/shared/classes" ]:
				ensure => directory,
				owner => $user,
				group => $group,
				mode => 2775;
			"/srv/tomcat/$name/shared/lib":
				ensure => symlink,
				target => "/srv/tomcat/shared/lib",
				require => [File["/srv/tomcat/$name"], File["/srv/tomcat/shared/lib"]];
		}

		# And copy over the server.xml and web.xml. Allow local
		# modification of these files by using "replace => false".
		file {
			"/srv/tomcat/$name/conf/server.xml":
				content => template("tomcat/shared/server.xml"),
				owner => "root",
				group => "root",
				mode => 0644,
				require => File["/srv/tomcat/$name/conf"],
				replace => false;
			"/srv/tomcat/$name/conf/web.xml":
				content => template("tomcat/$lsbdistcodename/web.xml"),
				owner => "root",
				group => "root",
				mode => 0644,
				require => File["/srv/tomcat/$name/conf"],
				replace => false;
			"/etc/tomcat5.5/$name.cfg":
				content => template("tomcat/$lsbdistcodename/instance.cfg"),
				owner => "root",
				group => "root",
				mode => 0644,
				replace => false,
				require => Package["tomcat5.5"];
		}
	}

	package { "tomcat5.5":
		ensure => installed,
	}

        if ($lsbdistcodename == "lenny") {
                package { "libtcnative-1":
                        ensure => installed,
                }
        }

	# Basic directory structure for running multiple Tomcat instances.
	file {	"/srv":
			ensure => directory,
			mode => 755;
		"/srv/tomcat":
			ensure => directory,
			mode => 755,
			require => File["/srv"];
		"/srv/tomcat/shared":
			ensure => directory,
			mode => 775,
			require => File["/srv/tomcat"];
		"/srv/tomcat/shared/lib":
			ensure => directory,
			mode => 775,
			require => File["/srv/tomcat/shared"];
		"/var/run/tomcat5.5":
			ensure  => directory,
			mode    => 775;
	}

	# This script actually starts all the instances we want on this machine
	file { "/etc/init.d/tomcat5.5.wrap":
		source => "puppet://puppet/tomcat/shared/init.d/tomcat5.5.wrap",
		mode => 755,
		owner => "root",
		group => "root",
	}

	# Make sure the original tomcat5.5 init script isn't started automatically.
	exec { "remove-package-initscript":
		command => "/usr/sbin/update-rc.d -f tomcat5.5 remove; /usr/sbin/update-rc.d tomcat5.5 stop 00 0 1 2 3 4 5 6 .",
		onlyif => "/bin/sh -c '[ -L /etc/rc2.d/S90tomcat5.5 ]'",
		require => Package["tomcat5.5"],
	}

	# Make sure our own wrapper script _is_ started on bootups
	exec { "add-custom-initscript":
		command => "/usr/sbin/update-rc.d tomcat5.5.wrap start 90 2 3 4 5 . stop 10 0 1 6 .",
		unless => "/bin/sh -c '[ -L /etc/rc2.d/S90tomcat5.5.wrap ]'",
		require => File["/etc/init.d/tomcat5.5.wrap"],
	}

	# This is a script that allows for starting multiple tomcat instances
	file { "/etc/init.d/tomcat5.5.multi":
		source => "puppet://puppet/tomcat/$lsbdistcodename/init.d/tomcat5.5.multi",
		mode => 755,
		owner => "root",
		group => "root",
		require => File["/var/run/tomcat5.5"],
	}
}
