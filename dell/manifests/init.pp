class dell::poweredge {
	include ipmi

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

	# Graph the IPMI sensors for temperature
	file { 
		"/etc/munin/plugin-conf.d/ipmi_sensor_":
			owner => "root",
			group => "root",
			mode => 644,
			source => "puppet://puppet/munin/client/plugin-conf.d/ipmi_sensor_";
		"/etc/munin/plugins/ipmi_sensor_u_degrees_c":
			ensure => symlink,
			owner => "root",
			group => "root",
			target => "/usr/local/share/munin/plugins/ipmi_sensor_",
			require => File["/etc/munin/plugin-conf.d/ipmi_sensor_"],
			notify => Service["munin-node"];
	}

	# SMART is not supported on the Dell drives
	file { "/etc/munin/plugins/hddtemp_smartctl":
		ensure => absent,
		notify => Service["munin-node"];
	}

	line { "module-e752x_edac":
		file => "/etc/modules",
		line => "e752x_edac"
	}
}

class dell::pe1955 inherits dell::poweredge {
	# RAID controller utility
	package { "mpt-status":
		ensure => installed,
	}

	service { "mpt-statusd":
		ensure => running,
		require => Package["mpt-status"]
	}

	line { "module-mptctl":
		file => "/etc/modules",
		line => "mptctl",
	}
}

class dell::pe1950 inherits dell::poweredge {
	include dell::perc

	file { "/etc/munin/plugins/ipmi_sensor_u_rpm":
		ensure => symlink,
		owner => "root",
		group => "root",
		target => "/usr/local/share/munin/plugins/ipmi_sensor_",
		require => File["/etc/munin/plugin-conf.d/ipmi_sensor_"],
		notify => Service["munin-node"];
	}
}

class dell::pe2950 inherits dell::pe1950 {
	include dell::perc

	file { "/etc/munin/plugins/ipmi_sensor_u_rpm":
		ensure => symlink,
		owner => "root",
		group => "root",
		target => "/usr/local/share/munin/plugins/ipmi_sensor_",
		require => File["/etc/munin/plugin-conf.d/ipmi_sensor_"],
		notify => Service["munin-node"];
	}
}

class dell::perc {
	package { "megacli":
		ensure => installed,
	}
}
