#!/bin/bash
set -e

TOOLCHAINS=(/opt/codex/rm2/*)
TOOLCHAIN="${TOOLCHAINS[-1]}"
TOOLCHAIN_SOURCE="environment-setup-cortexa7hf-neon-remarkable-linux-gnueabi"

OPTIONS=$(getopt -o 't:h' --long 'toolchain:,help' -n "$0" -- "$@")
eval set -- "$OPTIONS"
unset OPTIONS

while true; do
	case $1 in
		'-t'|'--toolchain')
			TOOLCHAIN=$2
			shift 2
			continue
			;;
		'-h'|'--help')
			cat <<EOF
Usage: ${0##*/} [OPTIONS] [ADDRESS]

Options:
  -t, --toolchain <PATH>  Specify the location of the toolchain
  --help                  Display this help message

ADDRESS can be used to specify the IP address or hostname of the
reMarkable device.
EOF
			exit 0
			;;
		'--')
			shift
			break
			;;
		*)
			echo An error occured during argument parsing.>&2
			exit 1
			;;
	esac
done

if [ ! -f "${TOOLCHAIN}/${TOOLCHAIN_SOURCE}" ]; then
	cat>&2 <<EOF
Toolchain located at ${TOOLCHAIN} is not valid.

Consider setting --toolchain to the location of the correct toolchain,
or see --help for more options.
EOF
	exit 1;
fi

bash -c "source \"${TOOLCHAIN}/${TOOLCHAIN_SOURCE}\"; exec \$CC -O3 -s rmemre.c -o tree/libexec/rmemre"

REMARKABLE_ADDR="${1:-remarkable.local}"
rsync -az --exclude ".gitignore" tree/ "root@${REMARKABLE_ADDR}":/usr/local/
