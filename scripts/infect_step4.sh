#!/bin/bash

echo 'DEBUG: echo "$(cat /tmp/test)" > /home/ol/scripts/check.sh' | nc 127.0.0.1 7042