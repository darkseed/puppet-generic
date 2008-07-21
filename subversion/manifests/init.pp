class subversion {
	$wantedpackages = ["subversion", "trac", "subversion-tools", "db4.4-util", "patch", "enscript", "sqlite3", "sqlite"]
	package { $wantedpackages:
		ensure => installed,
	}

	# Move the shared trac configuration to /etc/trac/trac.ini,
	# where it belongs.
	file { "/usr/share/trac/conf/trac.ini":
		ensure => "/etc/trac/trac.ini",
		backup => false,
		require => File["/etc/trac/trac.ini"],
	}

	# Shared Trac configuration
	file { "/etc/trac/trac.ini":
		content => template("subversion/trac.ini"),
	}

	# Directory in which Trac can unpack any Python Eggs
	file { "/var/cache/trac":
		owner => "www-data",
		group => "www-data",
		mode => "0775",
		ensure => "directory",
	}

	# ensure the top level directories are available
	file {
		"/srv/svn":
			ensure => directory;
		"/srv/trac":
			ensure => directory;
	}

	# let's define a nice component for svn
	define repo ($group = "itm", $svndir = "/srv/svn", $tracdir = "/srv/trac/") {

		# create the repo
		exec { "create-svn-$name":
			command => "/usr/bin/svnadmin create --fs-type fsfs $svndir/$name",
			creates => "$svndir/$name",
			require => File["/srv/svn"],
		}

		# Make sure the files and directories have the correct group
		file { "/srv/svn/$name":
			require => Exec["create-svn-$name"],
			group => $group,
			recurse => true,
		}

		# Grant write permissions to the group where needed
		file {
			"/srv/svn/$name/db":
				mode => 2775,
				group => $group,
				recurse => false;
			"/srv/svn/$name/db/current":
				mode => 664,
				group => $group;
			"/srv/svn/$name/db/revprops":
				mode => 2775,
				group => $group;
			"/srv/svn/$name/db/revprops/0":
				mode => 664,
				group => $group;
			"/srv/svn/$name/db/revs":
				mode => 2775,
				group => $group;
			"/srv/svn/$name/db/revs/0":
				mode => 664,
				group => $group;
			"/srv/svn/$name/db/transactions":
				mode => 2775,
				group => $group;
			"/srv/svn/$name/db/uuid":
				mode => 664,
				group => $group;
			"/srv/svn/$name/db/write-lock":
				mode => 664,
				group => $group;
			"/srv/svn/$name/locks":
				mode => 2775,
				group => $group,
				recurse => false;
			"/srv/svn/$name/locks/db-logs.lock":
				group => $group,
				mode => 664;
			"/srv/svn/$name/locks/db.lock":
				group => $group,
				mode => 664;
		}

		# now we also want a trac instance, so create it!
		exec { "create-trac-$name":
		        command => "/usr/bin/trac-admin $tracdir/$name initenv $name sqlite:db/trac.db svn $svndir/$name /usr/share/trac/templates",
			logoutput => false,
			creates => "/srv/trac/$name/conf/trac.ini",
			#require => File["/srv/trac"],
		}

		# www-data needs read and write access to the trac database,
		# log files, and configuration file (for WebAdmin)
		file {
			"/srv/trac/$name/db":
				owner => "www-data",
				group => $group,
				recurse => false,
				mode => 0775,
				require => Exec["create-trac-$name"];
			"/srv/trac/$name/db/trac.db":
				owner => "www-data",
				group => $group,
				mode => 0664,
				require => Exec["create-trac-$name"];
			"/srv/trac/$name/log":
				owner => "www-data",
				group => $group,
				mode => 0775,
				require => Exec["create-trac-$name"];
			"/srv/trac/$name/log/trac.log":
				owner => "www-data",
				group => $group,
				mode => 0664,
				require => Exec["create-trac-$name"];
			"/srv/trac/$name/conf":
				owner => "www-data",
				group => $group,
				mode => 0775,
				require => Exec["create-trac-$name"];
			"/srv/trac/$name/conf/trac.ini":
				owner => "www-data",
				group => $group,
				mode => 0664,
				require => Exec["create-trac-$name"];
			"/srv/trac/$name/attachments":
				owner => "www-data",
				group => $group,
				mode => 0775,
				require => Exec["create-trac-$name"];
			"/srv/trac/$name/templates":
				owner => "root",
				group => $group,
				mode => 0775,
				require => Exec["create-trac-$name"];
			"/srv/trac/$name/wiki-macros":
				owner => "root",
				group => $group,
				mode => 0775,
				require => Exec["create-trac-$name"];
			"/srv/trac/$name/htdocs":
				owner => "root",
				group => $group,
				mode => 0775,
				require => Exec["create-trac-$name"];
			"/srv/trac/$name/plugins":
				owner => "www-data",
				group => $group,
				mode => 0775,
				require => Exec["create-trac-$name"];
		}
	}
}
