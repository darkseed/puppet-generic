# Copied on 2010-02-04 from http://github.com/puppet-modules/puppet-common/raw/master/manifests/defines/concatenated_file.pp

# common/manifests/defines/concatenated_file.pp -- create a file from snippets
# stored in a directory
#
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

# not using the module_dir module
#module_dir { "common/cf": }

# TODO:
# * create the directory in _part too

# This resource collects file snippets from a directory ($dir) and concatenates
# them in lexical order of their names into a new file ($name). This can be
# used to collect information from disparate sources, when the target file
# format doesn't allow includes.
#
# concatenated_file_part can be used to easily configure content for this.
#
# If no $dir is specified, the target name with '.d' appended will be used.
#
# Depend on File[$name] to change if and only if its contents change. Notify
# Exec["concat_${name}"] if you want to force an update.
# 
# Usage:
#  concatenated_file { "/etc/some.conf":
#  	dir => "/etc/some.conf.d",
#  }
define concatenated_file (
	# where the snippets are located
	$dir = '',
	# a file with content to prepend
	$header = '',
	# a file with content to append
	$footer = '',
	# default permissions for the target file
	$mode = 0644, $owner = root, $group = 0,
	# notify on change
	$notify_on_change = false
	)
{

	$dir_real = $dir ? { '' => "${name}.d", default => $dir }

	$tmp_file_name = regsubst($dir_real, '/', '_', 'G')
	$tmp_file = "/tmp/${tmp_file_name}"

	if ! defined(Configfile[$dir_real]) {
		err("Directory $dir_real needs to be created by puppet.")
	}

	configfile { $tmp_file:
		ensure => present, checksum => md5,
		mode => $mode, owner => $owner, group => $group;
	}

	# decouple the actual file from the generation process by using a
	# temporary file and puppet's source mechanism. This ensures that events
	# for notify/subscribe will only be generated when there is an actual
	# change.
	configfile { $name:
		ensure => present, checksum => md5,
		source => $tmp_file,
		mode => $mode, owner => $owner, group => $group,
		require => Configfile[$tmp_file],
		notify => $notify_on_change ? {
			false   => undef,
			default => $notify_on_change
		},
	}

	# if there is a header or footer file, add it
	$additional_cmd = $header ? {
		'' => $footer ? {
			'' => '',
			default => "| cat - '${footer}' "
		},
		default => $footer ? { 
			'' => "| cat '${header}' - ",
			default => "| cat '${header}' - '${footer}' "
		}
	}

	# use >| to force clobbering the target file
	exec { "concat_${name}":
		command   => "/usr/bin/find ${dir_real} -maxdepth 1 -type f ! -name '*puppettmp' -print0 | sort -z | xargs -0 cat ${additional_cmd} >| ${tmp_file}",
		subscribe => [ File[$dir_real] ],
		before    => File[$tmp_file],
		alias     => [ "concat_${dir_real}"],
		loglevel  => debug,
	}
}


# Add a snippet called $name to the concatenated_file at $dir.
# The file can be referenced as File["cf_part_${name}"]
define concatenated_file_part (
	$dir, $content = '', $ensure = present,
	$mode = 0644, $owner = root, $group = 0 
	)
{

	configfile { "${dir}/${name}":
		ensure => $ensure, content => $content,
		mode => $mode, owner => $owner, group => $group,
		#alias => "cf_part_${name}",
		notify => Exec["concat_${dir}"],
	}

}
