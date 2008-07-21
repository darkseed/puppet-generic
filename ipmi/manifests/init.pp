class ipmi {
	define line($file, $line, $ensure = 'present') {
		case $ensure {
			default: {
				err("unknown ensure value ${ensure}")
			}
			present: {
				exec { "/bin/echo '${line}' >> '${file}'":
					unless => "/bin/grep -Fx '${line}' '${file}'"
				}
			}
			absent: {
				exec { "/usr/bin/perl -ni -e 'print unless /^\\Q${line}\\E\$/' '${file}'":
					onlyif => "/bin/grep -Fx '${line}' '${file}'"
				}
			}
		}
	}

	# Load the modules on boot
        line {
                "ipmi_devintf":
                        file => "/etc/modules",
                        line => "ipmi_devintf",
                        ensure => present;
                "ipmi_si":
                        file => "/etc/modules",
                        line => "ipmi_si",
                        ensure => present;
        }

        package { "ipmitool":
                ensure => installed,
        }

        file { "/etc/default/ipmievd":
                content => "ENABLED=true\n",
                require => Package["ipmitool"],
        }

        service { "ipmievd":
                ensure => running,
                require => File["/etc/default/ipmievd"],
        }
}
