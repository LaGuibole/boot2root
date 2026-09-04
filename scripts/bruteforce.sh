#!/bin/bash

KEY="$1"
WORDLIST="$2"

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <private_key> <wordlist>"
    exit 1
fi

while IFS= read -r password; do
    echo "Testing: [$password]"
    if ssh-keygen -y -P "$password" -f "$KEY" >/dev/null 2>&1; then
        echo "[+] Passphrase trouvée : $password"
        exit 0
    fi
done < "$WORDLIST"

echo "[-] Aucune passphrase trouvée."
exit 1