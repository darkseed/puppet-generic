# Copyright (C) 2010 Kumina bv, Tim Stoop <tim@kumina.nl>
# This works is published under the Creative Commons Attribution-Share 
# Alike 3.0 Unported license - http://creativecommons.org/licenses/by-sa/3.0/
# See LICENSE for the full legal text.

# Purpose:
#
# This allows you to add a line to a file if the line is not yet present in it.
# Useful for very simple configuration. Also used by the configfile define to
# keep track of files that are modified/added by puppet.
#
# Usage:
#
# name = Either a unique name or the line that needs to be added or removed.
# ensure = Either present or absent, if the line needs to be added or removed.
# file = The file location to which the line needs to be added or removed. If
#        the file does not exist, it will be created. If the directory doesn't
#        exist, this will fail.
# content = The actual line that needs to be added or removed. Can be left
#           empty if the name of the resource is the line you want to add
#           or remove.
#
# Example:
#
# line { "linkedin":
#	ensure  => "present",
#	file    => "/home/tim/my-social-networks",
#	content => "LinkedIn http://nl.linkedin.com/in/timstoop",
# }
#

define line (
	$ensure = "present", $file, $content = false) {

	if ! $content {
		$content = $name
	}

	case $ensure {
		default: {
			fail("Unknown ensure value: ${ensure}.")
		}
		present: {
			exec { "line $name":
				command => "/bin/echo '${content}' >> '${file}'",
				unless  => "/bin/grep -Fx '${content}' '${file}'";
			}
		}
		absent: {
			exec { "line $name":
				command => "/usr/bin/perl -ni -e 'print unless /^\\Q${content}\\E\$/' '${file}'",
				onlyif  => "/bin/grep -Fx '${content}' '${file}'";
			}
		}
	}
}

