host.pfx: host.crt
	openssl pkcs12 -export -in host.crt -inkey host.key -out host.pfx -password pass:

host.crt: host.csr rootCA.key rootCA.crt host.csr
	openssl x509 -req -in host.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out host.crt -days 365

rootCA.key:
	openssl genrsa -out rootCA.key 2048

rootCA.crt: rootCA.key
	openssl req -x509 -new -nodes -key rootCA.key -days 365 -out rootCA.crt  -subj '/C=US/ST=Texas/L=Dallas/CN=localhost'

host.key:
	openssl genrsa -out host.key 2048  -subj '/C=US/ST=Texas/L=Dallas/CN=localhost'

host.csr: host.key
	openssl req -new -key host.key -out host.csr  -subj '/C=US/ST=Texas/L=Dallas/CN=localhost'

openssl-server: cert.pem
	openssl s_server -accept 9932 -cert cert.pem -WWW

openssl-client:
	curl -k https://localhost:9932/Makefile
