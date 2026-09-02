#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <fichier>"
    exit 1
fi

sed \
    -e 's/&lt;/</g' \
    -e 's/&gt;/>/g' \
    -e 's/&#39;/'"'"'/g' \
    -e 's/,/,\n/g' \
    "$1"