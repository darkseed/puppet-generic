class nagios {
	package { ["nagios2", "nagios-plugins"]:
		ensure => installed,
	}

	service { "nagios2":
		ensure => running,
		require => Package["nagios2"],
	}

	# Allow external commands to be submitted through the web interface
	file {
		"/var/lib/nagios2":
			mode => 710,
			group => "www-data";
		"/var/lib/nagios2/rw":
			group => "www-data",
			mode => 2710;
	}
}

class nagios::nrpe {
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
