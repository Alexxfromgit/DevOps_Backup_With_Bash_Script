#!/bin/bash

bdir="/tmp/backups/"

if [ ! -d "${bdir}" ]; then
  mkdir "${bdir}"
fi

if [ "$#" -ne 2 ]; then
    echo "error: Illegal number of parameters" >&2;
    exit 1
fi

if ! [[ -d $1 ]]; then
    echo "error: $1 is a not a directory" >&2; 
    exit 2
fi

re='^[0-9]+$'
if ! [[ $2 =~ $re ]] ; then
   echo "error: $2 Not a number" >&2; 
   exit 3
fi

srcdir="${1}"
bnum="$2"
bname=$(echo "${1}" | sed -r 's/[/]+/-/g' | sed 's/^-//')
filename=${bname}-$(date '+%Y-%m-%d-%H%M%S').tar.gz

if ! tar --create --gzip --file="$bdir$filename" "${srcdir}" 2>/dev/null; then
    echo "error: failed to create backup of ${srcdir}" >&2
    exit 4
fi

if [ "$bnum" -gt 0 ]; then
    find "$bdir" -name "${bname}*" -type f -printf "${bdir}%P\n" | sort | head -n -"$bnum" | sed "s/.*/\"&\"/" | xargs rm -f
else
    find "$bdir" -name "${bname}*" -type f -delete
fi

exit 0
