# This Makefile is for automated checking of this pkgsrc collection
# for various programmatic and stylistic errors.

PKGLINT   = /usr/bin/pkglint
PKGMAN    = /usr/bin/pkgman
PKGSRCDIR = ${CURDIR}/*

define USAGE
Usage: make [OPTION...] [TARGET...] [PKGSRCDIR="PATH..."]
Check pkgsrc repo for typical errors.

OPTIONS:

  Make options.  See make(1) for more information.

TARGETS:

  check:
    pkglint     run pkglint(1) to check all packages for common issues
    check-urls  run pkglint(1) to check all packages for dead urls
    check-deps  check Pkgfiles for missing dependencies

endef

all: help

check: pkglint check-urls check-deps

# Check for invalid directories, junk files, SUID/SGID
# files and directories, and world-writeable files and directories.
pkglint:
	@${PKGLINT} -ijsw $(shell find ${CURDIR} \
		-mindepth 1 -maxdepth 1 -type d -not -name .git\*)

# Check for dead links.
check-urls:
	@${PKGLINT} -d $(shell find ${CURDIR} \
		-mindepth 1 -maxdepth 1 -type d -not -name .git\*)

# Check Pkgfiles for dependencies that are outside of this collection
# and/or outside of collections that this collection depends on or are
# completely missing.
check-deps-core:
	@${PKGMAN} --root= --no-std-config \
		--config-append="pkgsrcdir ${CURDIR}" \
		list-orphans --dependents | grep '(required by .*)' >&2 || :

######################################################################
%: %-core
	@true

help:
	@echo $(info ${USAGE})

.PHONY: all help pkglint check-urls

# vim: cc=72 tw=70
# End of file.
