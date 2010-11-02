require 'rexml/document'
include REXML
 
Puppet::Type.type(:xml_manipulator).provide :activemq_transportconnector do
    desc "The actual ActiveMQ config manipulator"

    defaultfor :operatingsystem => :debian
 
    def create
        file = File.open("/etc/activemq/activemq.xml", "r+")
        doc = REXML::Document.new file
	connectors = doc.elements["//transportConnectors"]
	connectors.add_element 'transportConnector', {'name' => resource[:type], 'uri' => resource[:uri]}
	file.rewind()
	doc.write( file, 4 )
    end
 
    def destroy
        file = File.open("/etc/activemq/activemq.xml", "r+")
        doc = REXML::Document.new file
	doc.root.elements.delete("transportConnect[@name=" + resource[:type] + "]")
	file.rewind()
	doc.write( file, 4 )
    end
 
    def exists?
        file = File.open("/etc/activemq/activemq.xml", "r+")
        doc = REXML::Document.new file
        XPath.match( doc, "//amq:transportConnector[@name=" + resource[:type] + " and @uri=" + resource[:uri] + "]", {"amq" => "http://activemq.apache.org/schema/core"}).length() > 0
    end
end
