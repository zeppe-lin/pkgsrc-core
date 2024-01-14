#!/bin/sh -
# Download glibc patch.
#
# Thanks to Steffen Nurpmeso <steffen at sdaoden.eu>.
# https://lists.crux.nu/pipermail/crux/2023-October/007401.html

. ./Pkgfile
curl -L -o glibc-$version.patch \
	"https://sourceware.org/git/?p=glibc.git;a=commitdiff_plain;hp=refs/tags/glibc-${version%-*};h=refs/heads/release/${version%-*}/master"

# End of file.
