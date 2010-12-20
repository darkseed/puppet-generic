class localbackup::common {
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
}

class localbackup::client {
	package { "local-backup":
		ensure => installed,
	}

	file { "/etc/backup/local-backup.conf":
		content => template("localbackup/local-backup.conf"),
		require => Package["local-backup"];
	}

	file { "/etc/backup/prepare.d/dpkg-list":
		ensure => symlink,
		target => "/usr/share/local-backup/prepare/dpkg-list",
		require => Package["local-backup"];
	}

	file { "/etc/backup/prepare.d/filesystems":
		ensure => symlink,
		target => "/usr/share/local-backup/prepare/filesystems",
		require => Package["local-backup"];
	}
}
