class gen_acpi {
	kpackage { "acpi-support-base":; }

	service { "acpid":
		hasstatus => true,
		ensure    => running,
		require   => Kpackage["acpi-support-base"];
	}
}
