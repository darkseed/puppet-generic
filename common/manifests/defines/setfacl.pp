define setfacl ($dir = false, $acl) {
	if $dir {
		$real_dir = $dir
	} else {
		$real_dir = $name
	}

	exec { "Set acls '${acl}' on ${real_dir}":
		command => "/usr/bin/setfacl -m ${acl} ${real_dir}",
		unless  => "/usr/bin/getfacl --absolute-names ${real_dir} | /bin/grep '${acl}'",
	}
}
