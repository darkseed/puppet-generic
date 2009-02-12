class subversion {
	package { "subversion":
		ensure => installed,
	}

	file { "/srv/svn":
		owner => "root",
		group => "root",
		mode => 755,
		ensure => directory,
	}

	# let's define a nice component for svn
	define repo($group, $path=false, $svn_via_dav=false, $mode="2755") {
		if $path {
			$svndir = $path
		} else {
			$svndir = "/srv/svn/$name"
		}
		
		# Set the correct group
		if $svn_via_dav {
			debug('Determined SVN will be used through DAV, change svnowner to www-data.')
			$svnowner = "www-data"
		} else {
			debug('Determined SVN will NOT be used through DAV, change svnowner to root.')
			$svnowner = "root"
		}

		# create the repo
		exec { "create-svn-$name":
			command => "/usr/bin/svnadmin create --fs-type fsfs $svndir",
			creates => "$svndir",
		}

		# Make sure the files and directories have the correct group
		file { "$svndir":
			require => Exec["create-svn-$name"],
			mode => $mode,
			owner => $svnowner,
			group => $group,
			recurse => false,
		}

		# Grant write permissions to the group where needed
		file {
			"$svndir/conf":
				mode => 2775,
				owner => $svnowner,
				group => $group,
				recurse => false;
			"$svndir/db":
				mode => 2775,
				owner => $svnowner,
				group => $group,
				recurse => false;
			"$svndir/db/current":
				mode => 664,
				owner => $svnowner,
				group => $group;
			"$svndir/db/revprops":
				mode => 2775,
				owner => $svnowner,
				group => $group;
			"$svndir/db/revprops/0":
				mode => 664,
				owner => $svnowner,
				group => $group;
			"$svndir/db/revs":
				mode => 2775,
				owner => $svnowner,
				group => $group;
			"$svndir/db/revs/0":
				mode => 664,
				owner => $svnowner,
				group => $group;
			"$svndir/db/transactions":
				mode => 2775,
				owner => $svnowner,
				group => $group;
			"$svndir/db/uuid":
				mode => 664,
				owner => $svnowner,
				group => $group;
			"$svndir/db/write-lock":
				mode => 664,
				owner => $svnowner,
				group => $group;
			"$svndir/locks":
				mode => 2775,
				owner => $svnowner,
				group => $group,
				recurse => false;
			"$svndir/hooks":
				mode => 775,
				owner => $svnowner,
				group => $group,
				recurse => false;
			"$svndir/hooks/post-commit.tmpl":
				mode => 664,
				owner => $svnowner,
				group => $group;
			"$svndir/hooks/post-lock.tmpl":
				mode => 664,
				owner => $svnowner,
				group => $group;
			"$svndir/hooks/post-revprop-change.tmpl":
				mode => 664,
				owner => $svnowner,
				group => $group;
			"$svndir/hooks/post-unlock.tmpl":
				mode => 664,
				owner => $svnowner,
				group => $group;
			"$svndir/hooks/pre-commit.tmpl":
				mode => 664,
				owner => $svnowner,
				group => $group;
			"$svndir/hooks/pre-lock.tmpl":
				mode => 664,
				owner => $svnowner,
				group => $group;
			"$svndir/hooks/pre-revprop-change.tmpl":
				mode => 664,
				owner => $svnowner,
				group => $group;
			"$svndir/hooks/pre-unlock.tmpl":
				mode => 664,
				owner => $svnowner,
				group => $group;
			"$svndir/hooks/start-commit.tmpl":
				mode => 664,
				owner => $svnowner,
				group => $group;
			"$svndir/locks/db-logs.lock":
				group => $group,
				owner => $svnowner,
				mode => 664;
			"$svndir/locks/db.lock":
				group => $group,
				owner => $svnowner,
				mode => 664;
			"$svndir/dav":
				group => $group,
				owner => $svnowner,
				mode => 2775;
		}
	}
}
