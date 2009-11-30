class sysctl {
	exec { "/sbin/sysctl -p /etc/sysctl.conf":
              	subscribe   => File["/etc/sysctl.conf"], 
               	refreshonly => true;
	}

	file { "/etc/sysctl.conf":
		checksum => "md5",
	}
}
