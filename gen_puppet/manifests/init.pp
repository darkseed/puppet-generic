class gen_puppet {
	if !$fqdn == "management.kumina.nl" {
		gen_apt::preference { ["puppet","puppet-common"]:; }
	}

	kpackage { "puppet":; }
}
