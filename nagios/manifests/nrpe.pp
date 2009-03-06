class nagios::nrpe {
	include nagios::nrpe::plugins

        define check($command) {
                file { "/etc/nagios/nrpe.d/$name.cfg":
                        owner => "root",
                        group => "root",
                        mode => 644,
                        content => "command[check_$name]=$command\n",
                        require => File["/etc/nagios/nrpe.d"],
                }
        }

	package { "nagios-nrpe-server":
		ensure => installed,
	}

	# We're starting NRPE from inetd, to allow it to use tcpwrappers for
	# access control.
	service { "nagios-nrpe-server":
		enable => false,
		ensure => stopped,
		pattern => "/usr/sbin/nrpe",
		hasrestart => true,
		require => Package["nagios-nrpe-server"],
	}

	service { "openbsd-inetd":
		ensure => running,
		pattern => "/usr/sbin/inetd",
	}

	exec { "update-services-add-nrpe":
		command => "/bin/echo 'nrpe\t\t5666/tcp\t\t\t# Nagios NRPE' >> /etc/services",
		unless => "/bin/grep -q ^nrpe /etc/services",
	}

	exec { "update-inetd-add-nrpe":
		command => "/usr/sbin/update-inetd --add '$ipaddress:nrpe stream tcp nowait nagios /usr/sbin/tcpd /usr/sbin/nrpe -c /etc/nagios/nrpe.cfg --inetd'",
		unless => "/bin/grep -q $ipaddress:nrpe /etc/inetd.conf",
		require => [Service["nagios-nrpe-server"], Exec["update-services-add-nrpe"]],
		notify => Service["openbsd-inetd"],
	}

	exec { "update-inetd-enable-nrpe":
		command => "/usr/sbin/update-inetd --enable $ipaddress:nrpe",
		unless => "/bin/grep -q ^$ipaddress:nrpe /etc/inetd.conf",
		require => Exec["update-inetd-add-nrpe"],
		notify => Service["openbsd-inetd"],
	}

	exec { "/bin/echo 'nrpe: $nagios_nrpe_client' >> /etc/hosts.allow":
		unless => "/bin/grep -Fx 'nrpe: $nagios_nrpe_client' /etc/hosts.allow",
		require => Exec["update-inetd-enable-nrpe"],
	}

	file {
		"/etc/nagios/nrpe.cfg":
			source => ["puppet://puppet/nagios/nrpe/${lsbdistcodename}/nrpe.cfg",
			           "puppet://puppet/nagios/nrpe/nrpe.cfg"],
			owner => "root",
			group => "root",
			mode => 644,
			require => Package["nagios-nrpe-server"];
		"/etc/nagios/nrpe.d":
			ensure => directory,
			owner => "root",
			group => "root",
			mode => 775,
			require => Package["nagios-nrpe-server"];
	}
}

class nagios::nrpe::plugins {
	include nagios::plugins

	# Check DRBD replication health
	check {
		"drbd":
			command => '/usr/local/lib/nagios/plugins/check_drbd -d All',
			require => File["/usr/local/lib/nagios/plugins/check_drbd"];
		"drbd_primary":
			command => '/usr/local/lib/nagios/plugins/check_drbd -d All -r Primary',
			require => File["/usr/local/lib/nagios/plugins/check_drbd"];
		"drbd_secondary":
			command => '/usr/local/lib/nagios/plugins/check_drbd -d All -r Secondary',
			require => File["/usr/local/lib/nagios/plugins/check_drbd"];
	}

	# aMaVis checks
	check {
		"amavis_scanner":
			command => '/usr/lib/nagios/plugins/check_smtp -H 127.0.0.1 -p 10024',
			require => File["/etc/nagios/nrpe.d"];
		"amavis_mta":
			command => '/usr/lib/nagios/plugins/check_smtp -H 127.0.0.1 -p 10025',
			require => File["/etc/nagios/nrpe.d"];
	}

	file { "/usr/local/lib/nagios/plugins/check_drbd":
		source => "puppet://puppet/nagios/plugins/check_drbd",
		owner => "root",
		group => "staff",
		mode => 755,
		require => File["/usr/local/lib/nagios/plugins"];
	}

	# Check puppetd freshness.
	check { "puppet_state_freshness":
		command => "/usr/lib/nagios/plugins/check_file_age -f /var/lib/puppet/state/state.yaml -w 14400 -c 21600",
	}

	# Make sure the latest installed kernel is also the running kernel.
	# (To reminds us to reboot a server after a kernel upgrade.)
	check { "running_kernel":
		command => "/usr/local/lib/nagios/plugins/check_running_kernel",
		require => File["/usr/local/lib/nagios/plugins/check_running_kernel"],
	}

	file { "/usr/local/lib/nagios/plugins/check_running_kernel":
		source => "puppet://puppet/nagios/plugins/check_running_kernel",
		owner => "root",
		group => "staff",
		mode => 755,
		require => File["/usr/local/lib/nagios/plugins"];
	}

	# Check the status of the bonding interfaces
	check { "bonding":
		command => "/usr/local/lib/nagios/plugins/check_bonding",
		require => File["/usr/local/lib/nagios/plugins/check_bonding"],
	}

	# This check is so we have a dependency for the backup machine. It checks if
	# there are processes called 'rdiff-backup', which would indicate an ongoing
	# backup. The CPU and Load checks depend on this check, so they won't fire
	# if backups are in progress.
	check { "rdiff-backup":
		command => "/usr/lib/nagios/plugins/check_procs -C rdiff-backup -w 0",
	}

	file { "/usr/local/lib/nagios/plugins/check_bonding":
		source => "puppet://puppet/nagios/plugins/check_bonding",
		owner => "root",
		group => "staff",
		mode => 755,
		require => File["/usr/local/lib/nagios/plugins"];
	}
}
