# Copyright (C) 2010 Kumina bv, Ed Schouten <ed@kumina.nl>
# This works is published under the Creative Commons Attribution-Share 
# Alike 3.0 Unported license - http://creativecommons.org/licenses/by-sa/3.0/
# See LICENSE for the full legal text.

class hosthenker {
	file { "/usr/bin/hosthenker":
		source => "puppet://puppet/hosthenker/hosthenker.sh",
		owner  => "root",
		group  => "root",
		mode   => 755;
	}
}
