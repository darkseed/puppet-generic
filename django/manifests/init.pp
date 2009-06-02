class django::common {
	package { "python-django":
		ensure => installed,
	}
}

class django::wsgi {
	# At this time, Apache is the only common webserver which supports
	# WSGI, so the below is Apache specific

	include django::common
	include apache

	package { "libapache2-mod-wsgi":
		ensure => installed,
	}

	apache::module { "wsgi":
		ensure => present,
		require => Package["libapache2-mod-wsgi"];
	}

	define site($wsgi_script=false, $wsgi_processes=2, $wsgi_threads=2,
		    $wsgi_path="/", $documentroot="/var/www", $aliases=false,
		    $address="*", $ssl=false, $ensure="present") {
		if ($wsgi_script == false) {
			$script = "$documentroot/dispatch.wsgi"
		}

		if ($ssl) {
			$template = "apache/sites-available/simple-ssl.erb"
		} else {
			$template = "apache/sites-available/simple.erb"
		}

		apache::site_config { $name:
			address => $address,
			template => $template,
			serveralias => $aliases,
			documentroot => $documentroot,
		}

		apache::site { $name:
			ensure => $ensure,
		}

		file { "/etc/apache2/vhost-additions/$name/django-wsgi.conf":
			owner => "root",
			group => "root",
			mode => 644,
			content => template("django/apache/wsgi.erb"),
			require => Apache::Module["wsgi"],
			notify => Exec["reload-apache2"],
		}
	}
}
