class squirrelmail {
	package { ["squirrelmail", "squirrelmail-locales"]:
		ensure => installed,
	}
}
