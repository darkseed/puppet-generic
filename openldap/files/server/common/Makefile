dummy: slapd_schema.conf slapd_main.conf slapd_backends.conf slapd_dbs.conf

slapd_schema.conf: schema-enabled/*
	@./create_slapd_conf schema-enabled > slapd_schema.conf

slapd_main.conf: slapd.main.d/*
	@./create_slapd_conf slapd.main.d > slapd_main.conf

slapd_backends.conf: slapd.backend.d/*
	@./create_slapd_conf slapd.backend.d > slapd_backends.conf

slapd_dbs.conf: slapd.db.d/*
	@./create_slapd_conf slapd.db.d > slapd_dbs.conf
