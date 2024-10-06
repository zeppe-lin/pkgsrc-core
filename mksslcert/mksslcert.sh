#!/bin/sh

print_help() {
	cat <<EOF
Usage: ${0##*/} key crt [hostname]
Create self-signed openssl certificates.

  key       full path to openssl private key
  crt       full path to openssl certificate
  hostname  host name of certificate
EOF
}

main() {
	if [ ! "$1" ] || [ ! "$2" ]; then
		print_help 1>&2
		exit 1
	fi
	
	KEY=$1
	CRT=$2
	FQDN=$(hostname -f) || FQDN=localhost
	if [ ! -z "$3" ]; then
		FQDN="$3"
	fi
	INFO=".\n.\n.\n.\n.\n$FQDN\nroot@$FQDN"
	OPTS="req -new -nodes -x509 -days 365 -newkey rsa:2048"
	
	printf "$INFO\n" | openssl $OPTS -out $CRT -keyout $KEY 2> /dev/null
	
	if [ $? -ne 0 ]; then
		echo "Error: creating of certificate failed" 1>&2
		exit 1
	else
		echo "SSL certificate $CRT with key $KEY for host $FQDN created"
		chmod 0600 "$CRT" "$KEY"
	fi
}

main "$@"

# End of file.
