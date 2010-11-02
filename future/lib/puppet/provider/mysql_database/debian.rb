require 'puppet/provider/package'

Puppet::Type.type(:mysql_database).provide(:debian,
		:parent => Puppet::Provider::Package) do

	desc "Use mysql as database."

	defaultfor :operatingsystem => :debian

	commands :mysqladmin => '/usr/bin/mysqladmin --defaults-file=/etc/mysql/debian.cnf'
	commands :mysql => '/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf'

	def query
		result = {
			:name => @resource[:name],
			:ensure => :absent
		}

		cmd = "#{command(:mysql)} mysql -NBe 'show databases'"
		execpipe(cmd) do |process|
			process.each do |line|
				if line.chomp.eql?(@resource[:name])
					result[:ensure] = :present
				end
			end
		end
		result
	end

	def self.instances
		databases = []

		cmd = "#{command(:mysql)} mysql -NBe 'show databases'"
		execpipe(cmd) do |process|
			process.each { |line|
				hash = {}
				hash[:name] = line.chomp
				hash[:provider] = self.name
				databases << new(hash)
				Puppet.debug(hash[:name])
			}
		end
		return databases
	end

	def create
		mysqladmin("--defaults-file=/etc/mysql/debian.cnf","create",@resource[:name])
	end

	def destroy
		mysqladmin("--defaults-file=/etc/mysql/debian.cnf","-f","drop",@resource[:name])
	end

	def exists?
		mysql("--defaults-file=/etc/mysql/debian.cnf","-NBe", "show databases", "mysql").match(/^#{@resource[:name]}$/)
	end
end

