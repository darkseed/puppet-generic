module Puppet::Parser::Functions
  newfunction(:bool2num, :type => :rvalue) do |args|
    case args[0]
      when "true"  then "1"
      when "false" then "0"
      when "1"     then "1"
      when "0"     then "0"
      when true    then "1"
      when false   then "0"
      else raise Puppet::ParseError, "Either specify true, false, 1 or 0."
      end
  end
end
