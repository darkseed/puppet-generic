# Copyright (C) 2010 Kumina bv, Tim Stoop <tim@kumina.nl>
# This works is published under the Creative Commons Attribution-Share 
# Alike 3.0 Unported license - http://creativecommons.org/licenses/by-sa/3.0/
# See LICENSE for the full legal text.

# Purpose:
#
# Using this version of the file resource, we can add some automation for easy
# deploys. Most notable, if a rmtsrc is given, the whole "puppet://puppet" part
# can be left out. Another automated task is that we keep track of files that
# are somehow modified or put on the system by puppet.
#
# Usage:
#
# Like the file type, mostly. The only addition is:
# - rmtsrc = As source, but will automagically prepend "puppet://puppet/" to
#            the string.
#
# Example:
#
#

define configfile ($backup = false, $checksum = false, $content = false, $ensure = "present",
		$force = false, $group = "root", $ignore = "", $links = "manage", $mode = "644",
		$owner = "root", $path = false, $purge = "false", $recurse = false, $replace = true,
		$source = false, $sourceselect = "first", $target = "notlink", $rmtsrc = false) {
	# We always want a path
	if ! $path { $usepath = $name }
	else       { $usepath = $path }

	if $rmtsrc and ! $source and ! $content { $usesource = "puppet://puppet/${rmtsrc}" }
	else { if $source and ! $rmtsrc and ! $content { $usesource = $source }
	else { $usesource = false } }

	file { $name:
		backup       => $backup,
		checksum     => $checksum ? {
			false   => undef,
			default => $checksum
		},
		content      => $content ? {
			false   => undef,
			default => $content
		},
		ensure       => $ensure,
		force        => $force,
		group        => $group,
		ignore       => $ignore,
		links        => $links,
		mode         => $mode,
		owner        => $owner,
		path         => $usepath,
		purge        => $purge,
		recurse      => $recurse,
		replace      => $replace,
		source       => $usesource ? {
			false   => undef,
			default => "$usesource",
		},
		sourceselect => $sourceselect,
		target       => $target ? {
			"notlink" => undef,
			default   => "$target",
		},
	}

	if $debug_manifest == "true" {
		line { 
			"keep track of added file $usepath":
				ensure  => $ensure ? {
					default => "present",
					absent  => "absent",
				},
				content => "$usepath",
				require => File[$name,"/var/cache/puppet-added-files"],
				file    => "/var/cache/puppet-added-files";
			"keep track of removed file $usepath":
				ensure  => $ensure ? {
					default => "absent",
					absent  => "present",
				},
				content => "$usepath",
				require => File[$name,"/var/cache/puppet-removed-files"],
				file    => "/var/cache/puppet-removed-files";
		}
	}
}

if $debug_manifest == "true" {
	# Create the actual files we use for this
	file { ["/var/cache/puppet-added-files","/var/cache/puppet-removed-files"]:
		ensure => "present",
		owner  => "root",
		group  => "root",
		mode   => 755,
	}

	# This makes sure we keep consistent
	line {
		"keep track of added file /var/cache/puppet-added-files":
			ensure  => $ensure ? {
				default => "present",
				absent  => "absent",
			},
			content => "/var/cache/puppet-added-files",
			require => File["/var/cache/puppet-added-files"],
			file    => "/var/cache/puppet-added-files";
		"keep track of added file /var/cache/puppet-removed-files":
			ensure  => $ensure ? {
				default => "absent",
				absent  => "present",
			},
			content => "/var/cache/puppet-removed-files",
			require => File["/var/cache/puppet-added-files"],
			file    => "/var/cache/puppet-added-files";
	}
}
