class openldap::client {
        package { ["ldap-utils", "libnss-ldap", "libpam-ldap", "nscd"]:
		ensure => installed,
	}

	# Need to move this to a separate modules - it conflicts with the bind
	# modules which also needs make.
	package { "make":
		ensure => installed,
	}

	$libldap = $lsbdistcodename ? {
		lenny => "libldap-2.4-2",
		default => "libldap2",
	}

	package { $libldap:
		ensure => installed,
		alias => libldap,
	}

	# The 'require => Exec["clear-nscd-cache"]' makes sure the nscd cache
	# gets cleared _before_ restarting nscd, but only if nscd.conf is
	# changed (because of "refreshonly => true" for the exec).
	service { "nscd":
		ensure => running,
		subscribe => [File["/etc/nscd.conf"], File["/etc/resolv.conf"]],
		require => Exec["clear-nscd-cache"],
	}

	file { "/etc/nscd.conf":
		source => "puppet://puppet/openldap/client/nscd.conf",
		owner => "root",
		group => "root",
		mode => 644,
		require => Package["nscd"],
	}

	# If the 'suggested-size' parameter in nscd.conf changes, the current
	# persistent cache needs to be blown away to allow nscd to rebuild the
	# databases with the new size.
	exec { "clear-nscd-cache":
		command => "/bin/rm -f /var/cache/nscd/*",
		logoutput => true,
		refreshonly => true,
		subscribe => File["/etc/nscd.conf"],
	}

	# Do a require on the packages below to enforce the order: first
	# install the package, then the config file.  That way the default
	# config files from the package will always be overwritten if the
	# package hasn't been installed yet.
	file {
		"/etc/ldap/ldap.conf":
			content => template("openldap/client/ldap.conf"),
			owner => "root",
			group => "root",
			mode => 644,
			require => Package["libldap"];
		"/etc/pam_ldap.conf":
			content => template("openldap/client/pam_ldap.conf"),
			owner => "root",
			group => "root",
			mode => 644,
			require => Package["libpam-ldap"];
		"/etc/libnss-ldap.conf":
			content => template("openldap/client/libnss-ldap.conf"),
			owner => "root",
			group => "root",
			mode => 644,
			require => Package["libnss-ldap"];
		"/etc/nsswitch.conf":
			source => "puppet://puppet/openldap/client/nsswitch.conf",
			owner => "root",
			group => "root",
			mode => 644,
			require => Package["libnss-ldap"];
	}

	# PAM settings. These also include the Kerberos settings, which is
	# somewhat awkward, but I don't know a better way to do this, since a
	# node can be a ldap client or a kerberos client, or neither, or both.
	file { "/etc/pam.d":
		source => "puppet://puppet/openldap/client/pam.d",
		recurse => true,
		mode => 644,
		owner => "root",
		group => "root",
	}
}

class openldap::server {
	define ldap::server::proxy_ad($ad_server_uri, $suffix) {
		file { "/etc/ldap/slapd.db.d/proxy_ad_$name.conf":
			owner => "root",
			group => "root",
			mode => 640,
			content => template("openldap/server/proxy_ad.conf"),
			notify => Exec["update-slapd-conf"],
			require => File["/etc/ldap/slapd.db.d"],
		}
	}

	define ldap::server::database($directory="", $suffix="", $admins=false, $storage_type="bdb") {
		# Ugly hack
		if $directory {
			$database_dir = $directory
		} else {
			$database_dir = "/var/lib/ldap/$name"
		}

		file { "/etc/ldap/slapd.db.d/$name.conf":
			owner => "openldap",
			group => "root",
			mode => 640,
			content => template("openldap/server/database.conf"),
			notify => Exec["update-slapd-conf"],
			require => File["/etc/ldap/slapd.db.d"],
		}

		file { "$database_dir":
			ensure => directory,
			owner => "openldap",
			group => "openldap",
			mode => 750,
		}
	}

	package { "slapd":
		ensure => installed,
	}

	service { "slapd":
		hasrestart => true,
		subscribe => [File["/etc/ldap/slapd.conf"],
		              Exec["update-slapd-conf"]],
		ensure => running,
	}

	file {
		"/etc/ldap/slapd.conf":
			source => ["puppet://puppet/openldap/server/$lsbdistcodename/slapd.conf", "puppet://puppet/openldap/server/slapd.conf"],
			owner => "openldap",
			group => "root",
			mode => 640,
			require => Package["slapd"];
		"/etc/ldap/slapd.main.d":
			ensure => directory,
			owner => "openldap",
			group => "root",
			mode => 750,
			require => Package["slapd"];
		"/etc/ldap/slapd.main.d/_dummy":
			ensure => file,
			owner => "openldap",
			group => "root",
			content => "# Needed for the Makefile, to ensure there's at least 1 file here. Do not remove.\n",
			require => File["/etc/ldap/slapd.db.d"];
		"/etc/ldap/slapd.backend.d":
			ensure => directory,
			owner => "openldap",
			group => "root",
			mode => 750,
			require => Package["slapd"];
		"/etc/ldap/slapd.backend.d/_dummy":
			ensure => file,
			owner => "openldap",
			group => "root",
			content => "# Needed for the Makefile, to ensure there's at least 1 file here. Do not remove.\n",
			require => File["/etc/ldap/slapd.db.d"];
		"/etc/ldap/slapd.backend.d/bdb.conf":
			source => "puppet://puppet/openldap/server/common/slapd.backend.d/bdb.conf",
			ensure => file,
			owner => "openldap",
			group => "root",
			mode => 644,
			require => File["/etc/ldap/slapd.db.d"],
			notify => Exec["update-slapd-conf"];
		"/etc/ldap/slapd.db.d":
			ensure => directory,
			owner => "openldap",
			group => "root",
			mode => 750,
			require => Package["slapd"];
		"/etc/ldap/slapd.db.d/_dummy":
			ensure => file,
			owner => "openldap",
			group => "root",
			content => "# Needed for the Makefile, to ensure there's at least 1 file here. Do not remove.\n",
			require => File["/etc/ldap/slapd.db.d"];
		"/etc/ldap/create_slapd_conf":
			source => "puppet://puppet/openldap/server/common/create_slapd_conf",
			owner => "root",
			group => "root",
			mode => 755,
			require => File["/etc/ldap/slapd.db.d"];
		"/etc/ldap/Makefile":
			source => "puppet://puppet/openldap/server/common/Makefile",
			owner => "root",
			group => "root",
			mode => 644,
			require => File["/etc/ldap/create_slapd_conf"];
	}

	# Creates /etc/ldap/slapd_includes.conf and /etc/ldap/slapd_dbs.conf,
	# which include the configuration files in /etc/ldap/slapd.db.d and
	# /etc/ldap/slapd.db.d respectively.
	exec { "update-slapd-conf":
		command => "/bin/sh -c 'cd /etc/ldap && make'",
		refreshonly => true,
		require => [File["/etc/ldap/Makefile"],
			    Package["make"]],
		notify => Service["slapd"],
	}
}
