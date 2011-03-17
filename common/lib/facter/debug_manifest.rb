File.exist?("/etc/puppet/debug_manifest") ? has_file = true : has_file = false
Facter.add("debug_manifest") do
	setcode do
		has_file
	end
end
