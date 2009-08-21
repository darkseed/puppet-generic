class mysql::common {
	package { "mysql-server-5.0":
		ensure => installed,
	}

	service { "mysql":
		hasrestart => true,
		hasstatus => true,
	}
}

class mysql::server {
	include mysql::common

	file { "/etc/mysql/my.cnf":
		content => template("mysql/my.cnf"),
		owner => root,
		group => root,
		mode => 0640,
	}

	file { "/etc/mysql/conf.d":
		ensure => directory,
		mode => 750,
		owner => "root",
		group => "root",
		require => Package["mysql-server-5.0"],
	}

	if ($mysql_serverid) {
		file { "/etc/mysql/conf.d/server-id.cnf":
			mode => 644,
			owner => "root",
			group => "root",
			content => "[mysqld]\nserver-id = $mysql_serverid\n",
			notify => Service["mysql"],
		}
	}

	file { "/etc/mysql/conf.d/binary-logging.cnf":
		mode => 644,
		owner => "root",
		group => "root",
		content => template("mysql/binary-logging.cnf"),
		notify => Service["mysql"],
	}
}

class mysql::slave inherits mysql::server {
	file { "/etc/mysql/conf.d/slave.cnf":
		owner => "root",
		group => "root",
		mode => 644,
		content => template("mysql/slave.cnf"),
		notify => Service["mysql"],
	}

	# Modified init script which waits for temporary tables to close.
	file { "/etc/init.d/mysql":
		source => "puppet://puppet/mysql/init.d/mysql",
		owner => "root",
		group => "root",
		mode => 755,
		require => Package["mysql-server-5.0"];
	}
}

class mysql::slave::delayed inherits mysql::slave {
	service { "mk-slave-delay":
		enable => true,
		require => File["/etc/init.d/mk-slave-delay"],
	}

	file {
		"/etc/mysql/conf.d/slave-delayed.cnf":
			source => "puppet://puppet/mysql/mysql/slave-delayed.cnf",
			owner => "root",
			group => "root",
			mode => 644,
			notify => Service["mysql"];
		"/etc/default/mk-slave-delay":
			owner => "root",
			group => "root",
			mode => 644,
			content => template("mysql/default/mk-slave-delay");
		"/etc/init.d/mk-slave-delay":
			owner => "root",
			group => "root",
			mode => 755,
			source => "puppet://puppet/mysql/init.d/mk-slave-delay",
			require => [File["/etc/default/mk-slave-delay"],
				    Package["maatkit"]];
		"/etc/logrotate.d/mk-slave-delay":
			source => "puppet://puppet/mysql/logrotate.d/mk-slave-delay",
			owner => "root",
			group => "root",
			mode => 644,
			require => Package["maatkit"];
	}

	package { "maatkit":
		ensure => installed,
	}
}
