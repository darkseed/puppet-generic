Puppet::Type.newtype(:xml_manipulator) do
    @doc = "Manage TransportConnectors for ActiveMQ"

    ensurable
 
    newparam(:uri) do
        desc "The uri on which the connector should listen"
    end
 
    newparam(:type) do
        desc "The connector type."

	isnamevar
    end
end

