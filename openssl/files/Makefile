requests := $(wildcard requests/*)
certificates := $(requests:requests/%=certs/%)

sign: $(certificates)

init:
	@test ! -f serial
	@mkdir -p newcerts requests
	@(umask 077; openssl req -new -set_serial 00 -days 1825 -x509 -newkey rsa:1024 -out cacert.pem -keyout private/cakey.pem)
	@touch index.txt
	@echo '01' > serial
	@chmod 644 cacert.pem

certs/%.pem: requests/%.pem
	@openssl ca -in $< -out $@
