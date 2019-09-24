# pfetch

A pretty system information tool written in POSIX `sh`.

```sh
➜ pfetch
    ___       goldie@KISS
   (.· |      os     KISS Linux
   (<> |      host   Lenovo YOGA 900-13ISK
  / __  \     kernel 5.3.1-coffee
 ( /  \ /|    uptime 6h 20m
_/\ __)/_)    pkgs   130
\/-____\/     memory 1721MiB / 7942MiB
```

## TODO

- [x] Store ascii "width" for dynamic padding.
- [ ] OS support.
    - [x] Linux
    - [ ] OpenBSD
    - [ ] FreeBSD
    - [ ] macOS
    - [ ] ???????
- [x] Add an environment variable for setting info.
