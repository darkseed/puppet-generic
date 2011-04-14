define ekfile ($ensure="present", $source=false, $path=false, $target=false, $content=false, $owner="root", $group="root", $mode="644", $recurse=false, $force=false, $purge=false, $tag=false) {
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
			recurse => $recurse,
			force   => $force,
			purge   => $purge,
			tag     => $tag;
		}
	}
}
