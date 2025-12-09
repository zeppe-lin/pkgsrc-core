#
# /etc/logrotate.d/boot: rotate bootlogd(8) output
#

/var/log/boot {
	monthly
	olddir /var/log/old
	postrotate
		/etc/rc.d/bootlogd restart
	endscript
}

# End of file.
