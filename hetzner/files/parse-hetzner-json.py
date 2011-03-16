#!/usr/bin/python
import simplejson as json, urllib2, ConfigParser, sys, urllib
from optparse import OptionParser

# Parse the commandline options
parser = OptionParser()
parser.add_option("-l", "--list",
                  action="store_true", dest="list_action", default=False,
                  help="get current settings")
parser.add_option("-g", "--get",
                  action="store_true", dest="get_action", default=False,
                  help="check whether the failover ip is pointing to us or not")
parser.add_option("-s", "--set",
                  action="store_true", dest="set_action", default=False,
                  help="set the failover IP to this host")
parser.add_option("-i", "--ip",
                  dest="failover_ip", default="0",
                  help="the failover ip to manipulate", metavar="FAILOVER-IP")
parser.add_option("-c", "--config",
		  dest="configfile", default="/etc/hetzner.cfg",
		  help="the location of the config file, defaults to /etc/hetzner.cfg", metavar="FILE")

(options, args) = parser.parse_args()

exit_ok=0
exit_error=2
exit_unknown=1

# Parse the configfile
config = ConfigParser.SafeConfigParser()
config.read(options.configfile)
section = config.sections()[0]

# Create the auth handler
pass_handler = urllib2.HTTPPasswordMgrWithDefaultRealm()
pass_handler.add_password(realm=None,
                          uri="https://robot-ws.your-server.de",
                          user=config.get(section,"user"),
			  passwd=config.get(section,"pass"))
auth_handler = urllib2.HTTPBasicAuthHandler(pass_handler)
opener = urllib2.build_opener(auth_handler)
urllib2.install_opener(opener)



def list_failover_ips():
	try:
		value = urllib2.urlopen("https://robot-ws.your-server.de/failover")
	except urllib2.HTTPError, e:
		print "HTTP Error code %s, cannot get list of ip's" % (e.code)
		sys.exit(exit_unknown)
	# Make from the json a python object
	data = json.load(value)
	# Get the ips
	ips = []
	for i in data:
		ips.append(i["failover"]["ip"])
	return ips

def get_failover_ip(ip):
	url = "https://robot-ws.your-server.de/failover/"+ip
	try:
		value = urllib2.urlopen(url)
	except urllib2.HTTPError, e:
		print "%s gives HTTP Error code %s, I don't know who has the failover IP %s" % (url,e.code,ip)
		sys.exit(exit_unknown)
	data = json.load(value)
	return data["failover"]["active_server_ip"]

def set_failover_ip(ip):
	url = "https://robot-ws.your-server.de/failover/"+ip
	data = urllib.urlencode({"active_server_ip":config.get(section,"local_ip")})
	value = urllib2.urlopen(url,data)
	data = json.load(value)
	return data["failover"]["active_server_ip"]

#Decide what we want to do
if options.list_action:
	if options.failover_ip == "0":
		for x in list_failover_ips():
			print x
		sys.exit(exit_ok)
	else:
		if options.failover_ip in list_failover_ips():
			sys.exit(exit_ok)
	sys.exit(exit_error)

elif options.get_action:
	# Check if the option is set
	if options.failover_ip == "0":
		raise ValueError, "Need to set the failover IP."
	# Check if the failover_ip is actually one we can use
	if not options.failover_ip in list_failover_ips():
		raise ValueError, "This failover IP is not assigned to the user in the config file."
	# Get the active ip for the failover ip
	active_ip = get_failover_ip(options.failover_ip)
	# Does the ip point to us?
	if config.get(section, "local_ip") == active_ip:
		print "Assigned to us."
		sys.exit(exit_ok)
	else:
		print "Not assigned to us, but to %s." % (active_ip)
		sys.exit(exit_error)

elif options.set_action:
	# Check if the option is set
	if options.failover_ip == "0":
		raise ValueError, "Need to set the failover IP."
	# Check if the failover_ip is actually one we can use
	if not options.failover_ip in list_failover_ips():
		raise ValueError, "This failover IP is not assigned to the user in the config file."
	if get_failover_ip(options.failover_ip) == config.get(section,"local_ip"):
		print "Already set."
		sys.exit(exit_ok)
	set_failover_ip(options.failover_ip)
	print "Set."
	sys.exit(exit_ok)
