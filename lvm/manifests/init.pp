class lvm {
	package { ["lvm2", "dmsetup"]:
		ensure => installed,
	}
}
