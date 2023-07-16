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
	@pkglint -ijsw $(shell find ${CURDIR} -mindepth 1 -maxdepth 1 \
		-type d -not -name .git\*)

# Check for dead links.
check-urls:
	@pkglint -d $(shell find ${CURDIR} -mindepth 1 -maxdepth 1 \
		-type d -not -name .git\*)

# Check Pkgfiles for dependencies that are outside of this collection
# and/or outside of collections that this collection depends on or are
# completely missing.
check-deps-core:
	@pkgman --root= --no-std-config                              \
		--config-append="pkgsrcdir ${CURDIR}"                \
		list-orphans -v | grep '(required by .*)' >&2 || :

######################################################################
%: %-core
	@true

help:
	@echo $(info ${USAGE})

.PHONY: all help
.PHONY: check-footprint check-urls
.PHONY: footprint-sugid footprint-wowr footprint-dirs footprint-junk

# vim: cc=72:tw=70
# End of file.
