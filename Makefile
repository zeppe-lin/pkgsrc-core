PKGSRCDIR = ${CURDIR}

define USAGE
Usage: make [OPTION...] [TARGET...] [PKGSRCDIR="PATH..."]
Check pkgsrc files for typical errors.

OPTIONS:

  Make options.  See make(1) for more information.

TARGETS:

  * check               perform all checks listed below:

  Check .footprint files for typical errors:
  ┌ check-footprint     perform all footprint checks listed below
  ├── footprint-sugid   check for SUID/SGID files and dirs
  ├── footprint-ww      check for world-writeable files and dirs
  ├── footprint-dirs    check for invalid directories like /usr/info
  └── footprint-junk    check for junk files like perllocal.pod, etc

  Check Pkgfiles for misdeclared dependencies:
  └ check-deps          check Pkgfiles for dependencies that are outside
                        of this collection and/or outside of collections
                        that this collection depends on or are completely
			missing
endef

all: help

check: check-footprint check-deps

######################################################################
# Check .footprint files for typical errors.                         #
######################################################################

check-footprint: footprint-sugid footprint-wowr footprint-dirs       \
	footprint-junk

# Check for SUID/SGID files and directories.
footprint-sugid:
	@awk >&2 '{                                                  \
	if ($$1 ~ /^[^d]..s....../)                                  \
	  print "suid file found: "FILENAME": "$$3;                  \
	if ($$1 ~ /^[^d].....s.../)                                  \
	  print "sgid file found: "FILENAME": "$$3;                  \
	if ($$1 ~ /^d..s....../)                                     \
	  print "suid directory found: "FILENAME": "$$3;             \
	if ($$1 ~ /^d.....s.../)                                     \
	  print "sgid directory found: "FILENAME": "$$3;             \
	}' ${PKGSRCDIR}/*/.footprint

# Check for world-writeable files and directories.
footprint-wowr:
	@awk >&2 '{                                                  \
        if ($$1 ~ /^d.......w[^t]/)                                  \
          print "world writeable directory found: "FILENAME": "$$0;  \
        if ($$1 ~ /^-.......w./)                                     \
          print "world writeable file found: "FILENAME": "$$0;       \
        }' ${PKGSRCDIR}/*/.footprint

# Check for invalid directories.
footprint-dirs:
	@awk >&2 '{                                                  \
	if ($$3 ~ /^usr\/share\/man\/whatis$$/)                      \
	   1; # skip manpages database                               \
	else if ($$3 ~ /^usr\/man\//                                 \
	 || $$3 ~ /^usr\/local\//                                    \
	 || $$3 ~ /^usr\/share\/locale\//                            \
	 || $$3 ~ /^usr\/share\/doc\//                               \
	 || $$3 ~ /^usr\/info\//                                     \
	 || $$3 ~ /^usr\/share\/info\//                              \
	 || $$3 ~ /^usr\/libexec\//                                  \
	 || $$3 ~ /^usr\/man\/\.\.\//                                \
	 || $$3 ~ /^usr\/share\/man\/\.\.\//                         \
	 ) print "invalid directory found: "FILENAME": "$$3;         \
	else if ($$3 ~ /^usr\/share\/man\/[^\/]+$$/)                 \
	   print "invalid man location found: "FILENAME": "$$3;      \
	}' ${PKGSRCDIR}/*/.footprint

# Check for junk files.
footprint-junk:
	@awk >&2 '{                                                  \
	if ($$3 ~ /\/.*\/perllocal\.pod$$/                           \
	 || $$3 ~ /\/perl5\/.*\/\.packlist$$/                        \
	 || $$3 ~ /\/perl5\/.*\/[^\/]+\.bs$$/                        \
	 ) print "junk file found: "FILENAME": "$$3;                 \
	}' ${PKGSRCDIR}/*/.footprint
	@awk >&2 -v IGNORECASE=1 '{                                  \
	if ($$3 ~ /^usr\/share\/terminfo\/n\/news$$/)                \
	   1; # skip ncurses terminfo file                           \
	else if ($$3 ~ /\/AUTHORS$$/                                 \
	 || $$3 ~ /\/BUGS$$/                                         \
	 || $$3 ~ /\/COPYING$$/                                      \
	 || $$3 ~ /\/CHANGELOG$$/                                    \
	 ||($$3 ~ /\/INSTALL$$/ && $$3 !~ /^usr\/bin\/install$$/)    \
	 || $$3 ~ /\/NEWS$$/                                         \
	 || $$3 ~ /\/README$$/                                       \
	 || $$3 ~ /\/README.TXT$$/                                   \
	 || $$3 ~ /\/README.md$$/                                    \
	 || $$3 ~ /\/THANKS$$/                                       \
	 || $$3 ~ /\/TODO$$/                                         \
	 ) print "junk file found: "FILENAME": "$$3;                 \
	}' ${PKGSRCDIR}/*/.footprint

# Check Pkgfiles for dependencies that are outside of this collection
# and/or outside of collections that this collection depends on or are
# completely missing.
check-deps-core:
	@pkgman --root= --no-std-config \
		--config-append="pkgsrcdir ${CURDIR}" \
		list-orphans -v | grep '(required by .*)'

######################################################################
%: %-core
	@ true

help:
	@echo $(info ${USAGE})

.PHONY: all help
.PHONY: check-footprint check-deps
.PHONY: footprint-sugid footprint-wowr footprint-dirs footprint-junk

# vim: cc=72:tw=70
# End of file.
