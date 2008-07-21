class ferm {
	define rule($table="filter", $chain="INPUT", $interface=false,
	            $outerface=false, $protocol=false, $saddr=false,
		    $daddr=false, $sport=false, $dport=false, $action) {
		file { "/etc/ferm/rules.d/$name.conf":
			content => template("ferm/rule.conf"),
			require => File["/etc/ferm/rules.d"];
		}
	}

	package { "ferm":
		ensure => installed,
	}

	service { "ferm":
		hasrestart => true,
		subscribe => [File["/etc/ferm/ferm.conf"],
		              File["/etc/ferm/rules.d"],
		              File["/etc/ferm/vars.d"]]
	}

	file {
		"/etc/ferm/ferm.conf":
			source => "puppet://puppet/ferm/ferm.conf",
			mode => 644,
			owner => "root",
			group => "root",
			require => [File["/etc/ferm/vars.d"], File["/etc/ferm/rules.d"]];
		"/etc/ferm/vars.d":
			ensure => directory,
			mode => 755,
			owner => "root",
			group => "root",
			require => Package["ferm"];
		"/etc/ferm/modules.d":
			ensure => directory,
			mode => 755,
			owner => "root",
			group => "root",
			require => Package["ferm"];
		"/etc/ferm/rules.d":
			ensure => directory,
			mode => 755,
			owner => "root",
			group => "root",
			require => Package["ferm"];
	}
}
