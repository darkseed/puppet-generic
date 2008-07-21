class debian::base {
	include apt

	$aptproxy = "http://apt-proxy:9999"

	define check_alternatives($linkto) {
		exec { "/usr/sbin/update-alternatives --set $name $linkto":
			unless => "/bin/sh -c '[ -L /etc/alternatives/$name ] && [ /etc/alternatives/$name -ef $linkto ]'"
		}
	}

	define staff_user($fullname, $uid) {
		$username = $name

		user { "$username":
			comment => $fullname,
			ensure => present,
			gid => "kumina",
			uid => $uid,
			groups => ["adm", "staff", "root"],
			membership => minimum,
			shell => "/bin/bash",
			home => "/home/$username",
			require => File["/etc/skel/.bash_profile"],
		}

		file { "/home/$username":
			ensure => directory,
			mode => 750,
			owner => "$username",
			group => "kumina",
			require => [User["$username"], Group["kumina"]],
		}

		file { "/home/$username/.ssh":
			source => "puppet://puppet/debian/home/$username/.ssh",
			mode => 700,
			owner => "$username",
			group => "kumina",
			require => File["/home/$username"],
		}

		file { "/home/$username/.ssh/authorized_keys":
			source => "puppet://puppet/debian/home/$username/.ssh/authorized_keys",
			mode => 644,
			owner => "$username",
			group => "kumina",
			require => File["/home/$username"],
		}

		file { "/home/$username/.bashrc":
			source => "puppet://puppet/debian/home/$username/.bashrc",
			mode => 644,
			owner => "$username",
			group => "kumina",
			require => File["/home/$username"],
		}

		file { "/home/$username/.bash_profile":
			source => "puppet://puppet/debian/home/$username/.bash_profile",
			mode => 644,
			owner => "$username",
			group => "kumina",
			require => File["/home/$username"],
		}

		file { "/home/$username/.bash_aliases":
			source => "puppet://puppet/debian/home/$username/.bash_aliases",
			mode => 644,
			owner => "$username",
			group => "kumina",
			require => File["/home/$username"],
		}

		file { "/home/$username/.darcs":
			ensure => directory,
			mode => 755,
			owner => "$username",
			group => "kumina",
			require => File["/home/$username"],
		}

		file { "/home/$username/.darcs/author":
			mode => 644,
			content => "$fullname <$username@kumina.nl>\n",
			group => "kumina",
			require => File["/home/$username/.darcs"],
		}
	}

	# Packages we want to have installed
	$wantedpackages = ["openssh-server", "vim", "less", "lftp", "screen",
	  "file", "debsums", "dlocate", "gnupg", "ucf", "elinks", "reportbug",
	  "tree", "netcat", "openssh-client", "tcpdump", "iproute", "acl",
	  "psmisc", "udev", "lsof", "bzip2", "deborphan", "strace", "pinfo",
	  "lsb-release", "ethtool", "mailx"]
	 package { $wantedpackages:
		 ensure => installed
	 }

        # Packages we do not need, thank you very much!
	$unwantedpackages = ["pidentd", "acpid", "cyrus-sasl2-doc",
	  "dhcp3-client", "dhcp3-common", "dictionaries-common",
	  "doc-linux-text", "doc-debian", "finger", "iamerican", "ibritish",
	  "ispell", "laptop-detect", "libident", "mutt", "mpack", "mtools",
	  "popularity-contest", "procmail", "tcsh", "w3m", "wamerican", "ppp",
	  "pppoe", "pppoeconf", "at", "mdetect", "tasksel"]
	package { $unwantedpackages:
		ensure => absent
	}

	# Ensure /tmp always has the correct permissions. (It's a common
	# mistake to forget to do a chmod 1777 /tmp when /tmp is moved to its
	# own filesystem.)
	file { "/tmp":
		mode => 1777,
	}

	service { "ssh":
		ensure => running,
		require => Package["openssh-server"],
	}

        # We want to use pinfo as infobrowser, so when the symlink is not
        # pointing towards pinfo, we need to run update-alternatives
        check_alternatives { "infobrowser":
                linkto => "/usr/bin/pinfo",
                require => Package["pinfo"]
        }

#	XXX Need to improve check_alternatives so it changes all slave links
#	for the alternative too. Which means using update-alternatives instead
#	of just changing the symlink.
#        alternative { "editor":
#                path => "/usr/bin/vim.basic",
#                require => Package["vim"]
#        }

	file { "/etc/skel/.bash_profile":
		owner => "root",
		group => "root",
		mode => 644,
		source => "puppet://puppet/debian/skel/bash_profile",
	}

	package { "adduser":
		ensure => installed,
	}
	file { "/etc/adduser.conf":
		source => "puppet://puppet/debian/adduser.conf",
		mode => 644,
		owner => "root",
		group => "root",
		require => Package["adduser"],
	}

	package { "sudo":
		ensure => installed,
	}

	file { "/etc/sudoers":
		source => "puppet://puppet/debian/sudoers",
		mode => 440,
		owner => "root",
		group => "root",
	}

	# Localization / internationalization settings
	file { "/var/cache/debconf/locales.preseed":
		owner => "root",
		group => "root",
		mode => 644,
		source => "puppet://puppet/debian/preseed/locales.preseed",
	}
	package { "locales":
		ensure => installed,
		require => File["/var/cache/debconf/locales.preseed"],
		responsefile => "/var/cache/debconf/locales.preseed",
	}

	# Mail on upgrades with cron-apt
	package { "cron-apt":
		ensure => installed,
	}
	file { "/etc/cron-apt/config":
		source => "puppet://puppet/debian/cron-apt/config",
		owner => "root",
		group => "root",
		mode => 644,
		require => Package["cron-apt"],
	}

        # Make sure udev doesn't generate persistent names - doesn't work with Xen
        # network interfaces. (Possibly because kernel 2.6.20 is needed, and 2.6.18
        # is currently installed. See /usr/share/doc/udev/README.Debian.gz for more.)
        # XXX Need to move this to a Xen specific module
	file { "/etc/udev/rules.d/z45_persistent-net-generator.rules":
		ensure => absent,
		backup => false,
		require => Package["udev"],
	}

        package { ["rwhod", "rwho"]:
                ensure => installed,
        }

        service { "rwhod":
                ensure => running,
                require => Package["rwhod"],
        }

        apt::source {
                "etch-base":
                        comment => "The current stable Debian release: Debian 4.0 / Etch.",
                        sourcetype => "deb",
                        uri => "$aptproxy/debian/",
                        distribution => "etch",
                        components => "main";
                "etch-security":
                        comment => "Security updates for Etch.",
                        sourcetype => "deb",
                        uri => "$aptproxy/security/",
                        distribution => "etch/updates",
                        components => "main";
                "etch-volatile":
                        comment => "Repository for volatile packages in Etch, such as SpamAssassin and Clamav",
                        sourcetype => "deb",
                        uri => "$aptproxy/debian-volatile/",
                        distribution => "etch/volatile",
                        components => "main";
                "kumina":
                        comment => "Local repository, for packages maintained by Kumina.",
                        sourcetype => "deb",
                        uri => "$aptproxy/kumina/",
                        distribution => "etch",
                        components => "main",
			require => Apt::Key["498B91E6"];
                "testing-base":
			ensure => absent,
                        comment => "Testing repository for newer Zope packages",
                        sourcetype => "deb",
                        uri => "$aptproxy/debian/",
                        distribution => "testing",
                        components => "main";
        }

	apt::key { "498B91E6":
		ensure => present,
	}

        file {
                "/etc/apt/preferences":
                        source => "puppet://puppet/debian/apt/preferences",
                        owner => "root",
                        group => "root",
                        mode => 644;
                "/etc/apt/apt.conf.d/release":
                        content => template("debian/apt/apt.conf.d/release"),
                        owner => "root",
                        group => "root";
        }

	# Add the Kumina group and users
	# XXX Needs to do a groupmod when a group with gid already exists.
	group { "kumina":
		ensure => present,
		gid => 1000,
	}

	staff_user {
		"bart":
			fullname => "Bart Cortooms",
			uid => 1000;
		"tim":
			fullname => "Tim Stoop",
			uid => 1001;
		"kees":
			fullname => "Kees Meijs",
			uid => 1002;
	}
}
