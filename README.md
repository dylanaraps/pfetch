# pfetch

A pretty system information tool written in POSIX `sh`.

The goal of this project is to implement a simple system information tool in POSIX `sh` using features built into the language itself (*where possible*).

The source code is highly documented and I hope it will act as a learning resource for POSIX `sh` and simple information detection across various different operating systems.

If anything in the source code is unclear or is lacking in its explanation, open an issue. Sometimes you get too close to something and you fail to see the "bigger picture"!

```sh
➜ pfetch
    ___       goldie@KISS
   (.· |      os     KISS Linux
   (<> |      host   Lenovo YOGA 900-13ISK
  / __  \     kernel 5.3.1-coffee
 ( /  \ /|    uptime 6h 20m
_/\ __)/_)    pkgs   130
\/-____\/     memory 1721M / 7942M
```

## OS support

- [x] Linux (A myriad of distributions)
- [x] MacOS
- [x] OpenBSD
- [x] FreeBSD
- [x] NetBSD
- [x] Haiku

## TODO

- [ ] Add optional and additional information detection.
    - [ ] CPU
    - [ ] Terminal Emulator
        - The way I implement this in `neofetch` is interesting.
    - [ ] Terminal colors
    - [ ] ???
- [ ] Expand operating system support.
    - [ ] Solaris ([#5](https://github.com/dylanaraps/pfetch/issues/5))
    - [ ] MINIX ([#6](https://github.com/dylanaraps/pfetch/issues/6))
    - [ ] AIX ([#7](https://github.com/dylanaraps/pfetch/issues/7))
    - [ ] IRIX ([#8](https://github.com/dylanaraps/pfetch/issues/8))
    - [ ] FreeMiNT ([#9](https://github.com/dylanaraps/pfetch/issues/9))
    - [ ] Windows ([#10](https://github.com/dylanaraps/pfetch/issues/10))
        - [ ] CYGWIN
        - [ ] MSYS
        - [ ] MINGW
        - [ ] WSL (*this is fairly simple*)

## Configuration

`pfetch` is configured through environment variables.

```sh
# Which information to display.
# NOTE: If 'ascii' will be used, it must come first.
# Default: first example below
# Valid: space separated string
#
# OFF by default: shell
PF_INFO="ascii title distro host kernel uptime pkgs memory"

# Example: Only ASCII.
PF_INFO="ascii"

# Example: Only Information.
PF_INFO="title distro host kernel uptime pkgs memory"

# Separator between info name and info data.
# Default: unset
# Valid: string
PF_SEP=":"

# Color of info names:
# Default: unset (auto)
# Valid: 0-9
PF_COL1=4

# Color of info data:
# Default: unset (auto)
# Valid: 0-9
PF_COL2=7

# Color of title data:
# Default: unset (auto)
# Valid: 0-9
PF_COL3=1

# Alignment padding.
# Default: unset (auto)
# Valid: int
PF_ALIGN=""

# Which ascii art to use.
# Default: unset (auto)
# Valid: string
PF_ASCII="openbsd"
```

## Credit

- [ufetch](https://gitlab.com/jschx/ufetch): Lots of ASCII logos.
