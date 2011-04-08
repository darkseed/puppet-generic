define ekfile ($ensure="present", $source=false, $path=false, $target=false, $content=false, $owner="root", $group="root", $mode="644", $require=false, $tag=false) {
	$kfilename = regsubst($name,'^(.*);.*$','\1')
	if !defined(Kfile["${kfilename}"]) {
		kfile { "${kfilename}":
			ensure  => $ensure,
			source  => $source,
			path    => $path,
			target  => $target,
			content => $content,
			owner   => $owner,
			group   => $group,
			mode    => $mode,
			require => $require,
			tag     => $tag;
		}
	}
}
