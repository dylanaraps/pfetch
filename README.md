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

## OS support

- [x] Linux
- [x] MacOS
    - [x] ~~Needs OS name detection.~~
    - [x] ~~Needs testing.~~
- [x] OpenBSD
    - [x] Needs used memory detection.
    - [x] Needs testing.
- [x] FreeBSD
    - [x] Needs used memory detection.
    - [x] Needs testing.
- [x] NetBSD
    - [x] Needs used memory detection.
    - [x] Needs testing.

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

## Make `pfetch` update on an interval

This makes `pfetch` display interactively like `htop`/`top`.

```sh
watch -tn1 pfetch
```

## Credit

- [ufetch](https://gitlab.com/jschx/ufetch): Lots of ASCII logos.
