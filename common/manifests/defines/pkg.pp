# Copyright (C) 2010 Kumina bv, Tim Stoop <tim@kumina.nl>
# This works is published under the Creative Commons Attribution-Share 
# Alike 3.0 Unported license - http://creativecommons.org/licenses/by-sa/3.0/
# See LICENSE for the full legal text.

define pkg (
		$ensure       = "installed",
		$provider     = "apt",
		$responsefile = false
		) {

	package { "$name":
		ensure       => $ensure,
		provider     => $provider,
		responsefile => $responsefile ? {
			false   => undef,
			default => $responsefile,
		},
		require      => Exec["apt-get update"],
	}

	if $debug_manifest == "true" {
		line {
			"keep track of installed package ${name}":
	                        ensure  => $ensure ? {
	                                default => "present",
	                                absent  => "absent",
	                        },
        	                content => "${name}",
                	        require => [File["/var/cache/puppet-added-packages"],Package[$name]],
                        	file    => "/var/cache/puppet-added-packages";
	                "keep track of removed package ${name}":
        	                ensure  => $ensure ? {
                	                default => "absent",
                        	        absent  => "present",
	                        },
        	                content => "${name}",
                	        require => [File["/var/cache/puppet-removed-packages"],Package[$name]],
                        	file    => "/var/cache/puppet-removed-packages";
	        }
	}
}

if $debug_manifest == "true" {
	configfile { ["/var/cache/puppet-added-packages","/var/cache/puppet-removed-packages"]:
		ensure => "present",
		owner  => "root",
		group  => "root",
		mode   => 755,
	}
}
