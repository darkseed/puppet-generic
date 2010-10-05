# Copyright (C) 2010 Kumina bv, Tim Stoop <tim@kumina.nl>
# This works is published under the Creative Commons Attribution-Share 
# Alike 3.0 Unported license - http://creativecommons.org/licenses/by-sa/3.0/
# See LICENSE for the full legal text.

class ksplice {
	# Add the source repo
	apt::source { "ksplice":
		uri          => "http://www.ksplice.com/apt",
		distribution => "lenny",
		components   => ["ksplice"],
	}

	# We manually download and import the key.
	exec { "import ksplice repository key":
		command => "/usr/bin/wget -qq -O - 'https://www.ksplice.com/apt/ksplice-archive.asc' | /usr/bin/apt-key add -",
		unless  => "/usr/bin/apt-key list | grep -q 'Ksplice APT Repository Signing Key'",
		require => [Package["wget"],Apt::Source["ksplice"]],
		notify  => Exec["/usr/bin/apt-get update"],
	}

	# Preseed the ksplice package
	file { "/var/cache/debconf/ksplice.preseed":
		source => "puppet:///modules/ksplice/ksplice.preseed",
		owner  => "root",
		group  => "root",
		mode   => 644,
	}

	# Install the ksplice package
	package { "uptrack":
		ensure       => latest,
		responsefile => "/var/cache/debconf/ksplice.preseed",
		require      => [File["/var/cache/debconf/ksplice.preseed"],Exec["import ksplice repository key"]],
		notify       => Exec["initial uptrack run"],
	}

	# Run the script when it's first installed
	exec { "initial uptrack run":
		command => "/usr/sbin/uptrack-upgrade -y",
		refreshonly => true,
	}

	# The modified configuration file
	file { "/etc/uptrack/uptrack.conf":
		source  => "puppet:///modules/ksplice/uptrack.conf",
		owner   => "root",
		group   => "root",
		mode    => 644,
		require => Package["uptrack"],
	}
}
