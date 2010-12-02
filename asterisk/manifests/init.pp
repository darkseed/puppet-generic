class asterisk::server {
	package {
		"asterisk":
			ensure => present;
		"asterisk-sounds-extra":
			ensure => present;
	}

	service {
		"asterisk":
			require => Package["asterisk"],
			ensure => running;
	}

	# Simple define to ease creation of Munin plugin links
	define munin_plugin {
		file { "/etc/munin/plugins/$name":
			ensure => link,
			target => "/usr/local/share/munin/plugins/$name",
		}
	}

	# Munin config
	munin_plugin {
		"asterisk_channels":;
		"asterisk_channelstypes":;
		"asterisk_codecs":;
		"asterisk_console":;
		"asterisk_iaxchannels":;
		"asterisk_iaxlag":;
		"asterisk_iaxpeers":;
		"asterisk_meetme":;
		"asterisk_meetmeusers":;
		"asterisk_modules":;
		"asterisk_sipchannels":;
		"asterisk_sipobjects":;
		"asterisk_sippeers":;
		"asterisk_voicemail":;
	}
}

class asterisk::zaptel-module-xen {
	$archdependent = $architecture ? {
		i386  => "zaptel-modules-2.6.26-2-xen-686",
		amd64 => "zaptel-modules-2.6.26-2-xen-amd64",
	}

	# Architecture dependent packages.
	package {
		$archdependent:
			require => Package["asterisk"],
			ensure => present;
	}
}
