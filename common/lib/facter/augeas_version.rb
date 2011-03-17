if  FileTest.exists?("/usr/bin/dpkg-query")
	Facter.add("augeas_version") do
		setcode do
			%x{/usr/bin/dpkg-query -W -f='${Version}' augeas-lenses}
		end
	end
end
