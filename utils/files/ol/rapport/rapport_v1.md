# Moulinette vs HAL9042 — preliminary report (v1, 8 pages — excerpt)

> Draft version, unencrypted. The final version (40 pages) is sealed in
> `rapport_final.enc`. You need all four key fragments to open it.

## Summary

Moulinette (2013) is deterministic. It compiles, it tests, it compares.
When it's wrong, you can read the code and understand why.

HAL9042 is probabilistic. It *estimates* a grade. When it's wrong — and it is
wrong at a measured rate of 0.61 — there is nothing to read. Just a number.

## Method

I replayed 2,400 evaluations by hand. wil confirmed 847 of them as aberrant.
The detail is in the final report. The worst cases:

- an empty `main.c` scored 125/100
- a complete, correct libft scored 0/100
- grades above the theoretical maximum (847/100 observed)

## Why it matters

A school that can no longer explain its grades has stopped teaching.
It administers an oracle.

*(continued in the sealed version — the password to the board PDF is in
fragments, like everything else.)*
