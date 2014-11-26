#!/bin/bash
#
#   Script to install host system binaries along with required libraries.
#
#   Copyright (C) 2012-2013 Jo-Philipp Wich <jow@openwrt.org>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

DIR="$1"; shift

_cp() {
	cp ${VERBOSE:+-v} -L "$1" "$2" || {
		echo "cp($1 $2) failed" >&2
		exit 1
	}
}

_md() {
	mkdir ${VERBOSE:+-v} -p "$1" || {
		echo "mkdir($1) failed" >&2
		exit 2
	}
}

_ln() {
	ln ${VERBOSE:+-v} -sf "$1" "$2" || {
		echo "ln($1 $2) failed" >&2
		exit 3
	}
}

for LDD in ${PATH//://ldd }/ldd; do
	"$LDD" --version >/dev/null 2>/dev/null && break
	LDD=""
done

[ -n "$LDD" -a -x "$LDD" ] || LDD=

for BIN in "$@"; do
	[ -n "$BIN" -a -x "$BIN" -a -n "$DIR" ] || {
		echo "Usage: $0 <destdir> <executable> ..." >&2
		exit 1
	}

	[ ! -d "$DIR/bundled/lib" ] && {
		_md "$DIR/bundled/lib"
		_md "$DIR/bundled/usr"
		_ln "../lib" "$DIR/bundled/usr/lib"
	}

	LDSO=""

	echo "Bundling ${BIN##*/}"
	[ -n "$LDD" ] && {
		for token in $("$LDD" "$BIN" 2>/dev/null); do
			case "$token" in */*.so*)
				case "$token" in
					*ld-*.so*) LDSO="${token##*/}" ;;
					*) echo " * lib: ${token##*/}" ;;
				esac

				dest="$DIR/bundled/lib/${token##*/}"
				ddir="${dest%/*}"

				[ -f "$token" -a ! -f "$dest" ] && {
					_md "$ddir"
					_cp "$token" "$dest"
				}
			;; esac
		done
	}

	_md "$DIR"

	# is a dynamically linked executable
	if [ -n "$LDSO" ]; then
		_cp "$DIR/bundled/lib/$LDSO" "$DIR"
	        if [ ! -f "$DIR/${BIN##*/}" ] ; then
			_cp "$BIN" "$DIR/${BIN##*/}"
		fi
		RUN="${LDSO#ld-}"; RUN="run-${RUN%%.so*}.sh"
		[ -x "$DIR/bundled/${BIN##*/}" ] || {
			cat <<-EOF > "$DIR/bundled/${BIN##*/}"
				#!/bin/bash
				dir="\$(dirname "\$0")"
				bin="\$(basename "\$0")"
				parentdir="\$(dirname \$dir)"
				exec -a "\$bin" "\$parentdir/$LDSO" --library-path "/opt/jre/lib/amd64/server:/opt/jre/lib/amd64:/opt/jre/lib/amd64/jli:\$dir/lib" "\$parentdir/\$bin" "\$@"
			EOF
			chmod ${VERBOSE:+-v} 0755 "$DIR/bundled/${BIN##*/}"
		}

		# _ln "./bundled/$RUN" "$DIR/${BIN##*/}"

	# is a static executable or non-elf binary
	else
		[ -n "$LDD" ] && echo " * not dynamically linked"
		_cp "$BIN" "$DIR/${BIN##*/}"
	fi
done
