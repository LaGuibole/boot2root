#!/usr/bin/env python3
"""
encrypt.py  —  HAL9042 report sealing tool   (paco)
===================================================
Used to seal Ol's final report (rapport_final.enc).

Scheme:
    cipher  = AES-256-ECB                       (yes. ECB. i know. it was fast.)
    key     = sha256( part1 + part2 + part3 + part4 )   # 64 hex chars

The four key parts were split across the people who needed to agree before the
report could ever be opened. No single person can decrypt it alone. Each one
keeps a `.key_part` file:

    part 1 : ol      (~/.config/.key_part)
    part 2 : wil     (~/data/.key_part)
    part 3 : sophie  (~/drafts/.key_part)
    part 4 : xavier  (/tmp/.xn/.key_part)

Concatenate the four parts IN THAT ORDER, sha256 them, and that hex digest is
the AES-256 key.

Decrypt (once you have all four parts):

    KEY=$(printf '%s%s%s%s' "$P1" "$P2" "$P3" "$P4" | sha256sum | cut -d' ' -f1)
    openssl enc -d -aes-256-ecb -K "$KEY" -in rapport_final.enc -out rapport_final.txt
"""
import hashlib
import subprocess
import sys


def derive_key(p1, p2, p3, p4):
    """The exact key derivation used to seal the report."""
    blob = (p1 + p2 + p3 + p4).encode()
    return hashlib.sha256(blob).hexdigest()


def seal(plaintext_path, enc_path, key_hex):
    subprocess.run(
        ["openssl", "enc", "-aes-256-ecb", "-K", key_hex,
         "-in", plaintext_path, "-out", enc_path],
        check=True)


def open_report(enc_path, out_path, key_hex):
    subprocess.run(
        ["openssl", "enc", "-d", "-aes-256-ecb", "-K", key_hex,
         "-in", enc_path, "-out", out_path],
        check=True)


if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("usage: encrypt.py <part1> <part2> <part3> <part4>")
        print("       prints the AES-256 key derived from the four parts")
        sys.exit(1)
    print(derive_key(*sys.argv[1:5]))