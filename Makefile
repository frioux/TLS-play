key.pem:
	openssl ecparam -out key.pem -name prime256v1 -genkey

cert.pem:
	openssl req \
	-x509 -nodes -days 365 \
	-subj '/C=US/ST=Texas/L=Dallas/CN=localhost' \
	-newkey rsa:1024 -keyout cert.pem -out cert.pem

openssl-server: cert.pem
	openssl s_server -accept 9932 -cert cert.pem -WWW

openssl-client:
	curl -k https://localhost:9932/Makefile
