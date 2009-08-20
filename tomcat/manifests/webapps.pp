class tomcat::webapps {
	package { "tomcat5.5-admin":
		ensure => present,
	}
}

class tomcat::webapps::admin {
	include tomcat::webapps

	define setup_for ($ensure = "present", $allow = "*", $path = "/admin") {
		file {
			["/srv/tomcat/$name/conf/Catalina",
			 "/srv/tomcat/$name/conf/Catalina/localhost"]:
				ensure => directory,
				owner => "tomcat55",
				mode => 775;
			"/srv/tomcat/$name/conf/Catalina/localhost/admin.xml":
				ensure => $ensure,
				content => template("tomcat/shared/Catalina/localhost/admin.xml"),
				owner => "tomcat55",
				group => "root",
				mode => 644,
				require => File["/srv/tomcat/$name/conf/Catalina/localhost"];
		}
	}
}

class tomcat::webapps::manager {
	include tomcat::webapps

	define setup_for ($ensure = "present", $path = "/manager") {
		file {
			["/srv/tomcat/$name/conf/Catalina",
			 "/srv/tomcat/$name/conf/Catalina/localhost"]:
				ensure => directory,
				owner => "tomcat55",
				mode => 775;
			"/srv/tomcat/$name/conf/Catalina/localhost/manager.xml":
				ensure => $ensure,
				content => template("tomcat/shared/Catalina/localhost/manager.xml"),
				owner => "tomcat55",
				group => "root",
				mode => 644,
				require => File["/srv/tomcat/$name/conf/Catalina/localhost"];
		}
	}
}

class tomcat::webapps::host-manager {
	include tomcat::webapps

	define setup_for ($ensure = "present", $path = "/host-manager") {
		file {
			["/srv/tomcat/$name/conf/Catalina",
			 "/srv/tomcat/$name/conf/Catalina/localhost"]:
				ensure => directory,
				owner => "tomcat55",
				mode => 775;
			"/srv/tomcat/$name/conf/Catalina/localhost/host-manager.xml":
				ensure => $ensure,
				content => template("tomcat/shared/Catalina/localhost/host-manager.xml"),
				owner => "tomcat55",
				group => "root",
				mode => 644,
				require => File["/srv/tomcat/$name/conf/Catalina/localhost"];
		}
	}
}
