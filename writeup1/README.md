# WRITEUP 1 - Boot2Root

## Contexte : Box HAL9042, sujet pedagogique de l'Ecole 42

### PHASE 1 - Reconnaissance / Enumeration:

#### ARP
```bash
┌──(kali㉿kali)-[~/boot2root_scripts]
└─$ arp -a
? (10.0.2.2) at 52:54:00:12:35:02 [ether] on eth0
c2r3p4.42lehavre.fr (10.12.3.4) at 00:be:43:89:f2:1d [ether] on eth1
```
#### NMAP
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

#### SMTP :  
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

#### DNS :  
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

### PHASE 2 - Attaque sur http://10.0.2.2:5042

Sur le navigateur, on nous sert cette page web :  
![image](../assets/roadmap/hal_web.png)  
En inspectant le code source de la page via cette requete:  
`curl http://10.0.2.2:5042`  
On tombe sur des indices interessants:  
```html
<!-- TODO: remove /api/debug before launch -->
<!-- debug.js still in /static/js/ pls remove -->
<!-- norm errors everywhere but ship it -->
```  
On enchaine alors:  
```bash
┌──(kali㉿kali)-[~/boot2root_scripts]
└─$ curl http://10.0.2.2:5042/api/debug                                                       
HAL9042 debug endpoint.
usage: ?file=<path>  |  ?cmd=<command>&token=<maintenance_token>
```