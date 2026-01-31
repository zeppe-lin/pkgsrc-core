README for git

---

GIT SERVER
==========

The following instructions will install a git server.  It will be set
up to use OpenSSH as the secure remote access method.

Set Up Users, Groups, and Permissions
-------------------------------------

You will need to be user root for the initial portion of
configuration.  Create the git user and group and set an unusable
password hash with the following commands:

```sh
groupadd -g 58 git
useradd -m -g git -s /usr/bin/git-shell -u 58 git
sed -i '/^git:/s/^git:[^:]:/git:NP:/' /etc/shadow
```

Putting in an unusable password hash (replacing the ! by NP) unlocks
the account but it cannot be used to login via password
authentication.  That is required by `sshd` to work properly.  Next,
create some files and directories in the home directory of the git
user allowing access to the git repository using ssh keys.

```sh
install -o git -g git -m 0700 -d /home/git/.ssh
install -o git -g git -m 0600 /dev/null /home/git/.ssh/authorized_keys
```

For any developer who should have access to the repository add his/her
public ssh key to `/home/git/.ssh/authorized_keys`.  First, prepend
some options to prevent users from using the connection to git for
port forwarding to other machines the git server might reach.

```sh
cat <<EOF | sudo tee -a /home/git/.ssh/authorized_keys
no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty
EOF
cat <user-ssh-key> | sudo tee -a /home/git/.ssh/authorized_keys
```

It is also useful to set the default name of the initial branch of new
repositories by modifying the git configuration.  As the root user,
run:

```sh
git config --system init.defaultBranch master
```

Finally add the `/usr/bin/git-shell` entry to the `/etc/shells`
configuration file.  This shell has been set in the git user profile
and is to make sure that only git related actions can be executed:

```sh
vim /etc/shells
```

Create a git repository
-----------------------

The repository can be anywhere on the filesystem. It is important that
the git user has read/write access to that location.  We use
`/srv/git` as base directory.  Create a new git repository with the
following commands (as the root user):

**NOTE:  In all the instructions below, we use project1 as an example
repository name.  You should name your repository as a short
descriptive name for your specific project.**

```sh
install -o git -g git -m 0755 -d /srv/git/project1.git
cd /srv/git/project1.git
git init --bare
chown -R git:git .
```

You may clone existing repository from other machine:

```sh
mkdir /srv/git
cd /srv/git
git clone --bare git@gitserver/project1.git
chown -R git:git .
```

Populate the repository from a client system
--------------------------------------------

**IMPORTANT:  All the instructions in this section and the next should
be done on a user system, not the server system.**

Now that the repository is created, it can be used by the developers
to put some files into it.  Once the ssh key of the user is imported
to git's `authorized_keys` file, the user can interact with the
repository.

A minimal configuration should be available on the developer's system
specifying its user name and the email address.  Create this minimal
configuration file on client side:

```sh
cat > ~/.gitconfig <<EOF
[user]
name = <users-name>
email = <users-email-address>
EOF
```

On the developer's machine, set up some files to be pushed to the
repository as the initial content:

**IMPORTANT:  The gitserver term used below should be the host name
(or IP address) of the git server.**

```sh
mkdir myproject
cd myproject
git init --initial-branch=master
git remote add origin ssh://git@gitserver:/srv/git/project1.git
cat >README <<EOF
This is the README file
EOF
git add README
git commit -m 'Initial creation of README'
git push --set-upstream origin master
```

The initial content is now pushed to the server and is available for
other users.  On the current machine, the argument `--set-upstream
origin master` is now no longer required as the local repository is
now connected to the remote repository.  Subsequent pushes can be
performed as

```sh
git push
```

Other developers can now clone the repository and do modifications to
the content (as long as their ssh keys has been installed):

```sh
git clone git@gitserver:/srv/git/project1.git
cd project1
vi README
git commit -am 'Fix for README file'
git push
```

**NOTE: This is a very basic server setup based on OpenSSH access.
All developers are using the git user to perform actions on the
repository and the changes users are committing can be distinguished
as the local user name (see ~/.gitconfig) is recorded in the
changesets.**

Access is restricted by the public keys added to git's
`authorized_keys` file and there is no option for the public to
export/clone the repository.  To enable this, continue with step 4 to
set up the git server for public read-only access.

In the URL used to clone the project, the absolute path (here
`/srv/git/project1.git`) has to be specified as the repository is not
in git's home directory but in `/srv/git`.  To get rid of the need to
expose the structure of the server installation, a symlink can be
added in git's home directory for each project like this:

```sh
ln -svf /srv/git/project1.git /home/git/
```

Now, the repository can be cloned using:

```sh
git clone git@gitserver:project1.git
```

Configure the Server
--------------------

The setup described above makes a repository available for
authenticated users (via providing the ssh public key file).  There is
also a simple way to publish the repository to unauthenticated users
-- of course without write access.

The combination of access via ssh (for authenticated users) and the
export of repositories to unauthenticated users via the daemon is in
most cases enough for a development site.

**NOTE:  The daemon will be reachable at port 9418 by default.  Make
sure that your firewall setup allows access to that port.**

In order to allow git to export a repository, a file named
`git-daemon-export-ok` is required in each repository directory on the
server.  The file needs no content, just its existence enables, its
absence disables the export of that repository.

```sh
touch /srv/git/project1.git/git-daemon-export-ok
```

To start the server, edit the git-daemon RC script included in the git
package: 

```sh
vim /etc/rc.d/gitd
```

The script to start the git daemon uses some default values
internally.  Most important is the path to the repository directory
which is set to `/srv/git`.  In case you have for whatever reason
created the repository in a different location, you'll need to tell
the RC script where the repository is to be found.

After modifying some defaults in `/etc/rc.d/gitd`, you need to prevent
the loss of your data upon update.  Make sure you edited
`/etc/pkgadd.conf` and added the following line:

```
UPGRADE    ^/etc/rc.d/gitd$    NO
```

To start the server at boot time, add the `gitd` into the `SERVICE`
variable in `/etc/rc.conf`:

```sh
SERVICE='... gitd'
```

---

GITWEB
======

The following instructions will configure the gitweb service using
`gitweb(1)` and `lighttpd(8)`.

Configure gitweb
----------------

First, we need to make a gitweb configuration file.  Open
`/etc/gitweb.conf` or create if it doesn't exist) with the following
content:

```perl
#
# /etc/gitweb.conf: Gitweb configuration file
#

# The directories where your projects are.  Must not end with
# a slash.
our $projectroot = "/path/to/your/repos";

# Base URLs for links displayed in the web interface.
our @git_base_url_list = qw(
    git://<your server>
    ssh://git@<your server>/srv/git
    );

# vim: ft=perl
# End of file.
```

Configure lighttpd
------------------

Adjust your `/etc/lighttpd.conf` to the following setup:

```perl
#
# /etc/lighttpd.conf: lighttpd(8) configuration
#

# to use mod_rewrite you have to compile lighttpd with libpcre
# installed
server.modules = ("mod_accesslog")
server.modules += (
    "mod_alias", "mod_cgi", "mod_redirect", "mod_setenv"
)
url.redirect += ("^/gitweb$" => "/gitweb/")
alias.url += ("/gitweb/" => "/usr/share/gitweb/")

server.port = 80
server.username = "www"
server.groupname = "www"
server.pid-file = "/run/lighttpd.pid"

# ssl support
#server.port = 443
#ssl.engine = "enable"
#ssl.pemfile = "/etc/ssl/certs/lighttpd.pem"

# chrooted operation
#server.chroot = "/var/www/lighttpd"
#server.document-root = "/htdocs"
#server.errorlog = "/logs/error_log"
#server.upload-dirs = ( "/tmp" )
#accesslog.filename = "/logs/access_log"

# non-chrooted operation
server.document-root = "/usr/src/zeppe-lin.github.io"
server.errorlog = "/var/www/lighttpd/logs/error_log"
accesslog.filename = "/var/www/lighttpd/logs/access_log"

server.dir-listing = "enable"
server.indexfiles = (
    "index.html", "index.htm", "default.htm", "gitweb.cgi"
)

mimetype.assign = (
    ...

    # Needed for Gitweb to display properly.
    ".css" => "text/css",
)

$HTTP["url"] =~ "^/gitweb/" {
    setenv.add-environment = (
        "GITWEB_CONFIG" => "/etc/gitweb.conf",
        "PATH" => env.PATH
    )
    cgi.assign = (".cgi" => "")
    server.indexfiles = ("gitweb.cgi")
}

# End of file.
```

---

End of file.
