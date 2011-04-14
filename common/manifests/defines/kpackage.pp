define kpackage ($ensure="present", $responsefile=false, $tag=false) {
	package { "${name}":
		ensure       => $ensure,
		responsefile => $responsefile ? {
			false   => undef,
			default => $responsefile,
		},
		require      => Exec["/usr/bin/apt-get update"],
		tag          => $tag ? {
			false   => undef,
			default => $tag,
		};
	}
}
