define kfile ($ensure="present", $content=false, $source=false, $path=false, $target=false, $owner="root", $group="root", $mode="0644", $recurse=false, $force=false, $purge=false, $tag=false) {
	file { "${name}":
		ensure  => $ensure,
		content => $content ? {
			false   => undef,
			default => $content,
		},
		source  => $source ? {
			false   => undef,
			default => "puppet:///modules/${source}",
		},
		path    => $path ? {
			false   => undef,
			default => $path,
		},
		target  => $target ? {
			false   => undef,
			default => $target,
		},
		owner   => $owner,
		group   => $group,
		mode    => $ensure ? {
			directory => $mode ? {
				"0644"   => "0755",
				default =>  $mode,
			},
			default   => $mode,
		},
		recurse => $recurse ? {
			false   => undef,
			default => $recurse,
		},
		force   => $force ? {
			false   => undef,
			default => $force,
		},
		purge   => $purge ? {
			false   => undef,
			default => $purge,
		},
		tag     => $tag ? {
			false   => undef,
			default => $tag,
		};
	}
}
