#!/bin/bash

if [ "$#" -eq 0 ]; then
    echo "Usage: $0 \"<file_path>\""
    exit 1
fi

FILE="$*"

curl "http://10.0.2.2:5042/api/debug?file=$FILE"