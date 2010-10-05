# backupsshkey.rb

Facter.add("backupsshkey") do
	setcode do
		value = nil
		if FileTest.file?("/etc/backup/ssh_key.pub")
			File.open("/etc/backup/ssh_key.pub") { |f|
			    value = f.read.chomp.split(/\s+/)[1]
			}
		end
		value
	end
end
