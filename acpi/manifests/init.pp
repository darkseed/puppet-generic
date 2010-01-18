class acpi::enabled {
	package {
		"acpi-support-base":
			ensure => present;
	}

	service {
		"acpid":
			require => Package["acpi-support-base"],
			hasstatus => true,
			ensure => running;
	}
}

class acpi::disabled {
	package {
		"acpid":
			ensure => absent;
	}
}
