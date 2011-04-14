class gen_apt {
	if $lsbmajdistrelease < 6 {
		include gen_puppet::concat

		$preferences_file = "/etc/apt/preferences"

		concat { $preferences_file:
			owner   => "root",
			group   => "root",
			mode    => 440;
		}
	} else {
		kfile { "/etc/apt/preferences":
			ensure => absent;
		}
	}

	kfile {
		# Putting files in a directory is much easier to manage with
		# Puppet than modifying /etc/apt/sources.lists.
		"/etc/apt/sources.list":
			ensure => absent,
			notify => Exec["/usr/bin/apt-get update"];
		"/etc/apt/sources.list.d":
			ensure  => directory,
			notify  => Exec["/usr/bin/apt-get update"];
		"/etc/apt/keys":
			ensure => directory;
		# Increase the available cachesize
		"/etc/apt/apt.conf.d/50cachesize":
			content => "APT::Cache-Limit \"33554432\";\n",
			notify  => Exec["/usr/bin/apt-get update"];
	}

	# Run apt-get update when anything beneath /etc/apt/sources.list.d changes
	exec { "/usr/bin/apt-get update":
		refreshonly => true;
	}
}

define gen_apt::preference($package=false, $repo=false, $prio="999") {
	$use_repo = $repo ? {
		false   => "${lsbdistcodename}-backports",
		default => $repo,
	}

	if $lsbmajdistrelease > 5 {
		kfile { "/etc/apt/preferences.d/${name}":
			content => template("gen_apt/preference"),
			notify  => Exec["/usr/bin/apt-get update"];
		}
	} else {
		add_rule { "${name}":
			content => template("gen_apt/preference"),
			notify  => Exec["/usr/bin/apt-get update"];
		}
	}
}

define gen_apt::source($uri, $sourcetype="deb", $distribution="stable", $components=[], $ensure="file", $comment=false) {
	kfile { "/etc/apt/sources.list.d/${name}.list":
		ensure  => $ensure,
		content => template("gen_apt/source.list"),
		require => File["/etc/apt/sources.list.d"],
		notify  => Exec["/usr/bin/apt-get update"],
	}
}

define gen_apt::key {
	exec { "/usr/bin/apt-key add /etc/apt/keys/${name}":
		unless  => "/usr/bin/apt-key list | grep -q ${name}",
		require => File["/etc/apt/keys/${name}"],
		notify  => Exec["/usr/bin/apt-get update"];
	}

	kfile { "/etc/apt/keys/${name}":
		source => "kbp_apt/keys/${name}";
	}
}

define gen_apt::add_rule($content, $order=15) {
	kbp_concat::add_content { $name:
		content => $content,
		order   => $order,
		target  => "/etc/apt/preferences";
	}
}
