class gen_sudo {
	kpackage { "sudo":; }
	# Setup /etc/sudoers for either .d inclusion or concatination
	if $lsbmajdistrelease > 5 { # Squeeze and newer
		kfile { "/etc/sudoers.d/":
			ensure  => directory,
			source  => "gen_sudo/sudoers.d/",
			recurse => true,
			purge   => true,
			mode    => 440;
		}

		kfile { "/etc/sudoers":
			content => "#includedir /etc/sudoers.d\n",
			owner   => "root",
			group   => "root",
			mode    => 440,
			require => Package["sudo"];
		}
	} else { # Lenny and older
		include gen_puppet::concat
		$sudoers="/etc/sudoers" #in squeeze or higher we could use /etc/sudoers.d/ and put all the sudo config there.

		concat { $sudoers:
			owner   => "root",
			group   => "root",
			mode    => 440,
			require => Package["sudo"];
		}

		# This define is internal to gen_sudo and only needed on Lenny and older hosts
		define add_rule($content, $order=15) {
			gen_puppet::concat::add_content { $name:
				content => $content,
				order   => $order,
				target  => "/etc/sudoers";
			}
		}
	}

	define rule($entity, $command, $as_user, $password_required = true, $comment = false, $order = 15) {
		$the_comment = $comment ? {
			false   => $name,
			default => $comment
		}
		if $lsbmajdistrelease > 5 { # Squeeze or newer
			kfile { "/etc/sudoers.d/${name}":
				mode => 440,
				content => template("gen_sudo/sudo.erb"),
			}
		} else {
			add_rule { "${name}":
				content => template("gen_sudo/sudo.erb"),
				order   => $order;
			}
		}
	}
}
