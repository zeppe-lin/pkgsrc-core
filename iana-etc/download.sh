#!/bin/sh -
#@ Update protocols and services from IANA.
#@ Taken from ArchLinux script written by Gaetan Bisson.
#@ Adjusted for CRUX by Juergen Daubert <jue@jue.li>.
#@ Adjusted for Zeppe-Lin by Alexandr Savca <alexandr.savca89@gmail.com>.

awk=awk
curl=curl
url_pn='https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xml'
url_snpn="https://www.iana.org/assignments/service-names-port-numbers/\
service-names-port-numbers.xml"

timestamp() {
	sed -nr 's|\s*<updated>([0-9\-]+)</updated>|\1|p' $1 | head -1
}

download() {
	echo 'Downloading protocols'
	${curl} -o protocols.xml ${url_pn}
	[ ${?} -eq 0 ] || exit 20
	echo 'Downloading services'
	${curl} -o services.xml ${url_snpn}
	[ ${?} -eq 0 ] || exit 21
}

process() {
	echo 'Processing protocols'
	${awk} -F "[<>]" -v URL="${url_pn}" -v DT="$(timestamp protocols.xml)" '
		BEGIN{
			print "#"
			print "# /etc/protocols: protocols definition file"
			print "#"
			print "# See protocols(5) for more information."
			print "#"
			print ""
			print "# Last updated: " DT
			print "# Source:       " URL
			print ""
		}
		/<record/ {v = n = ""}
		/<value/ {v = $3}
		/<name/ && $3!~/ / {n = $3}
		/<\/record/ && n && v != ""{
			printf "%-12s %3i %s\n", tolower(n), v, n
		}
		END{
			print ""
			print "# End of file."
		}
	' < protocols.xml > protocols.new
	[ ${?} -eq 0 ] || exit 30

	echo 'Processing services'
	${awk} -F "[<>]" -v URL="${url_snpn}" -v DT="$(timestamp services.xml)" '
		BEGIN{
			print "#"
			print "# /etc/services: internet network services list"
			print "#"
			print "# See services(5) for more information."
			print "#"
			print ""
			print "# Last updated: " DT
			print "# Source:       " URL
			print ""
		}
		/<record/ {n = u = p = c = ""}
		/<name/ && !/\(/ {n = $3}
		/<number/ {u = $3}
		/<protocol/ {p = $3}
		/Unassigned/ || /Reserved/ || /historic/ {c = 1}
		/<\/record/ && n && u && p && !c{
			printf "%-15s %5i/%s\n", n, u, p
		}
		END{
			print ""
			print "# End of file."
		}
	' < services.xml > services.new
	[ ${?} -eq 0 ] || exit 31
}

update() {
	mv protocols.new protocols
	[ ${?} -eq 0 ] || exit 40
	mv services.new services
	[ ${?} -eq 0 ] || exit 41
	rm -f protocols.xml services.xml
	[ ${?} -eq 0 ] || exit 42
}

download
process
update


# End of file.
