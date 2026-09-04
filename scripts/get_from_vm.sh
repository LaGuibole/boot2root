#!/bin/bash

if [ "$#" -eq 0 ]; then
    echo "Usage: $0 \"<file_path>\""
    exit 1
fi

FILE="$*"

scp -P 6060 paco@10.0.2.2:"$FILE" . 