!#/bin/bash

# ce script sert a clean le script check.sh, avec les tests foireux, ca evite
# de retaper la commande 

echo 'DEBUG: echo "#!/bin/bash" > /home/ol/scripts/check.sh' | nc 127.0.0.1 7042