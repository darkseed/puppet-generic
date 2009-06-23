class trac {
	package { ["trac", "enscript", "sqlite3", "python-setuptools"]:
		ensure => installed,
	}

	# Move the shared trac configuration to /etc/trac/trac.ini,
	# where it belongs.
	file { "/usr/share/trac/conf/trac.ini":
		ensure => "/etc/trac/trac.ini",
		owner => "root",
		group => "root",
		mode => 644,
		backup => false,
		require => File["/etc/trac/trac.ini"],
	}

	# Shared Trac configuration
	file { "/etc/trac/trac.ini":
		content => template("trac/trac.ini"),
		owner => "root",
		group => "root",
		mode => 644,
		require => Package["trac"],
	}

	# Directory in which Trac can unpack any Python Eggs
	file { "/var/cache/trac":
		owner => "www-data",
		group => "www-data",
		mode => "0775",
		ensure => "directory",
	}

	file { "/srv/trac":
		ensure => directory;
	}

	define environment($group, $path=false, $svnrepo=false) {
		if $path {
			$tracdir = $path
		} else {
			$tracdir = "/srv/trac/$name"
		}

		if $svnrepo {
			$svndir = $svnrepo
		} else {
			$svndir = "/srv/svn/$name"
		}

		# Create the Trac environment
		exec { "create-trac-$name":
		        command => "/usr/bin/trac-admin $tracdir initenv $name sqlite:db/trac.db svn $svndir /usr/share/trac/templates",
			logoutput => false,
			creates => "$tracdir/conf/trac.ini",
			require => Package["trac"],
		}

		# www-data needs read and write access to the trac database,
		# log files, and configuration file (for WebAdmin)
		file {
			"$tracdir":
				owner => "www-data",
				group => $group,
				recurse => false,
				mode => 0750,
				require => Exec["create-trac-$name"];
			"$tracdir/db":
				owner => "www-data",
				group => $group,
				recurse => false,
				mode => 0775,
				require => Exec["create-trac-$name"];
			"$tracdir/db/trac.db":
				owner => "www-data",
				group => $group,
				mode => 0664,
				require => Exec["create-trac-$name"];
			"$tracdir/log":
				owner => "www-data",
				group => $group,
				mode => 0775,
				require => Exec["create-trac-$name"];
			"$tracdir/log/trac.log":
				owner => "www-data",
				group => $group,
				mode => 0664,
				require => Exec["create-trac-$name"];
			"$tracdir/conf":
				owner => "www-data",
				group => $group,
				mode => 0775,
				require => Exec["create-trac-$name"];
			"$tracdir/conf/trac.ini":
				owner => "www-data",
				group => $group,
				mode => 0664,
				require => Exec["create-trac-$name"];
			"$tracdir/attachments":
				owner => "www-data",
				group => $group,
				mode => 0775,
				require => Exec["create-trac-$name"];
			"$tracdir/templates":
				owner => "root",
				group => $group,
				mode => 0775,
				require => Exec["create-trac-$name"];
			"$tracdir/wiki-macros":
				owner => "root",
				group => $group,
				mode => 0775,
				require => Exec["create-trac-$name"];
			"$tracdir/htdocs":
				owner => "root",
				group => $group,
				mode => 0775,
				require => Exec["create-trac-$name"];
			"$tracdir/plugins":
				owner => "www-data",
				group => $group,
				mode => 0775,
				require => Exec["create-trac-$name"];
		}
	}
}
