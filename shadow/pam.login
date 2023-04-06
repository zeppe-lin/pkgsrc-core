#
# /etc/pam.d/login - login service module configuration
#

# include common auth settings
auth        include     common-auth

# check to make sure that root is allowed to login, see securetty(5)
auth        required    pam_securetty.so

# check to make sure that the user is allowed to login
auth        requisite   pam_nologin.so

# include common account settings
account     include     common-account

# include common password settings
password    include     common-password

# include common session settings
session     include     common-session

# display date of last login
session     optional    pam_lastlog.so

# display the message of the day
session     optional    pam_motd.so

# End of file.
