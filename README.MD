# BOOT2ROOT - Hal9042 Evaluation Server

## Resume : 

Compromission complete du serveur `HAL9042` via deux methodes distinctes, jusqu'a l'obtention d'un shell root interactif.
L'ensemble des 10 flags mandatory ainsi que les 5 flags bonus ont ete recuperes.

## Organisation du projet :

| Fichier / Dossier | Contenu                                                     |
|-------------------|-------------------------------------------------------------|
| [/scripts](/scripts/)          | L'ensemble des scripts qui ont pu servir au cours du projet |
| [/utils/LOGBOOK.md](/utils/LOG_BOOK.md) | Mon journal de bord illisible                               |
| [/writeup1](/writeup1/write_up_1.md)         | WriteUp exposant la LFI (Local File Inclusion)              |
| [/writeup2](/writeup2/write_up_2.md)         | WriteUp exposant la SSTI (Server Side Template Injection)   |
| [/writeup3](/writeup3/write_up_3.md)         | Obtention des 15 flags + Kill Chain privesc                 |
| [/assets](/assets/roadmap/)           | Les screens qui ont servi au tout debut pour le LOGBOOK.md  |

> [!IMPORTANT]
> **Avis aux etudiants 42** : Le sujet ne ment pas, ce projet prend du temps, et c'est justement le temps demande par ce projet et les difficultes rencontrees au long du chemin qui en font son essence. Ne consultez pas les writeup si vous faites acutellement ce projet, prenez le temps d'analyser, certains flags ne vont vous apparaitre evident qu'a la fin du projet. C'est le but. 
> **Pour le reste** : Vous pouvez consulter les WriteUp, selon mon niveau de fatigue au moment de la redaction, la qualite redactionnelle peut en etre impactee, pardonnez-moi d'avance.

## Succes : 

### Users :

| Ordre | Utilisateur |     | Done ?|
|-------|-------------|-----|-------|
|   1   | www-data    | 💻  |   ✅  |
|   2   | paco        | 🔐  |   ✅  |
|   3   | wil         | 🕵️  |   ✅  |
|   4   | sophie      | 🧠  |   ✅  |
|   5   | ol          | 🛡️  |   ✅  |
|   6   | root        | 👑  |   ✅  |

### Flags :

| Numero | Flag                                        |
|--------|---------------------------------------------|
| 1      | FLAG{n1c3_try_but_th4ts_n0t_h0w_th1s_w0rks} |
| 2      | FLAG{d3l3t3d_us3rs_l34v3_tr4c3s}            |
| 3      | FLAG{x4v13r_w4s_3r4s3d_but_n0t_g0n3}        |
| 4      | FLAG{h4l_r3v13ws_3v3ry_4pp34l}              |
| 5      | FLAG{b4sh_h1st0ry_1s_4_d14ry}               |
| 6      | FLAG{udp_1s_4_wh1sp3r}                      |
| 7      | FLAG{r3c0n_1s_king}                         |
| 8      | FLAG{g1t_n3v3r_f0rg3ts}                     |
| 9      | FLAG{s3m1_bl1nd_st1ll_burns}                |
| 10     | FLAG{www_d4t4_1s_just_th3_b3g1nn1ng}        |
| 11     | FLAG{p4c0_l3ft_th3_k3ys_und3r_th3_m4t}      |
| 12     | FLAG{d3bug_m0d3_1s_4_f34tur3_r1ght}         |
| 13     | FLAG{w1l_kn3w_f1rst_n0b0dy_l1st3n3d}        |
| 14     | FLAG{cr0n_j0bs_4r3_tr4ps_4nd_g1fts}         |
| 15     | FLAG{m0ul1n3tt3_w4a_n3v3r_ju5t_4_scr1pt}    |