If you want to bind MySQL to all interfaces, you can use:

mysql::config { "dummy-name":
	bindaddress => "all",
}
