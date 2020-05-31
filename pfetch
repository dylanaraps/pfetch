#!/bin/sh
#
# pfetch - Simple POSIX sh fetch script.

log() {
    # The 'log()' function handles the printing of information.
    # In 'pfetch' (and 'neofetch'!) the printing of the ascii art and info
    # happen independently of each other.
    #
    # The size of the ascii art is stored and the ascii is printed first.
    # Once the ascii is printed, the cursor is located right below the art
    # (See marker $[1]).
    #
    # Using the stored ascii size, the cursor is then moved to marker $[2].
    # This is simply a cursor up escape sequence using the "height" of the
    # ascii art.
    #
    # 'log()' then moves the cursor to the right the "width" of the ascii art
    # with an additional amount of padding to add a gap between the art and
    # the information (See marker $[3]).
    #
    # When 'log()' has executed, the cursor is then located at marker $[4].
    # When 'log()' is run a second time, the next line of information is
    # printed, moving the cursor to marker $[5].
    #
    # Markers $[4] and $[5] repeat all the way down through the ascii art
    # until there is no more information left to print.
    #
    # Every time 'log()' is called the script keeps track of how many lines
    # were printed. When printing is complete the cursor is then manually
    # placed below the information and the art according to the "heights"
    # of both.
    #
    # The math is simple: move cursor down $((ascii_height - info_height)).
    # If the aim is to move the cursor from marker $[5] to marker $[6],
    # plus the ascii height is 8 while the info height is 2 it'd be a move
    # of 6 lines downwards.
    #
    # However, if the information printed is "taller" (takes up more lines)
    # than the ascii art, the cursor isn't moved at all!
    #
    # Once the cursor is at marker $[6], the script exits. This is the gist
    # of how this "dynamic" printing and layout works.
    #
    # This method allows ascii art to be stored without markers for info
    # and it allows for easy swapping of info order and amount.
    #
    # $[2] ___      $[3] goldie@KISS
    # $[4](.· |     $[5] os KISS Linux
    #     (<> |
    #    / __  \
    #   ( /  \ /|
    #  _/\ __)/_)
    #  \/-____\/
    # $[1]
    #
    # $[6] /home/goldie $

    # End here if no data was found.
    [ "$2" ] || return

    # Store the value of '$1' as we reset the argument list below.
    name=$1

    # Use 'set --' as a means of stripping all leading and trailing
    # white-space from the info string. This also normalizes all
    # white-space inside of the string.
    #
    # Disable the shellcheck warning for word-splitting
    # as it's safe and intended ('set -f' disables globbing).
    # shellcheck disable=2046,2086
    {
        set -f
        set +f -- $2
        info=$*
    }

    # Move the cursor to the right, the width of the ascii art with an
    # additional gap for text spacing.
    printf '[%sC' "${ascii_width--1}"

    # Print the info name and color the text.
    printf '[3%s;1m%s[m' "${PF_COL1-4}" "$name"

    # Print the info name and info data separator.
    printf %s "$PF_SEP"

    # Move the cursor backward the length of the *current* info name and
    # then move it forwards the length of the *longest* info name. This
    # aligns each info data line.
    printf '[%sD[%sC' "${#name}" "${PF_ALIGN:-$info_length}"

    # Print the info data, color it and strip all leading whitespace
    # from the string.
    printf '[3%sm%s[m\n' "${PF_COL2-7}" "$info"

    # Keep track of the number of times 'log()' has been run.
    info_height=$((${info_height:-0} + 1))
}

get_title() {
    # Username is retrieved by first checking '$USER' with a fallback
    # to the 'id -un' command.
    user=${USER:-$(id -un)}

    # Hostname is retrieved by first checking '$HOSTNAME' with a fallback
    # to the 'hostname' command.
    #
    # Disable the warning about '$HOSTNAME' being undefined in POSIX sh as
    # the intention for using it is allowing the user to overwrite the
    # value on invocation.
    # shellcheck disable=SC2039
    hostname=${HOSTNAME:-${hostname:-$(hostname)}}

    log "[3${PF_COL3:-1}m${user}${c7}@[3${PF_COL3:-1}m${hostname}" " " >&6
}

get_os() {
    # This function is called twice, once to detect the distribution name
    # for the purposes of picking an ascii art early and secondly to display
    # the distribution name in the info output (if enabled).
    #
    # On first run, this function displays _nothing_, only on the second
    # invocation is 'log()' called.
    [ "$distro" ] && {
        log os "$distro" >&6
        return
    }

    case $os in
        Linux*)
            # Some Linux distributions (which are based on others)
            # fail to identify as they **do not** change the upstream
            # distribution's identification packages or files.
            #
            # It is senseless to add a special case in the code for
            # each and every distribution (which _is_ technically no
            # different from what it is based on) as they're either too
            # lazy to modify upstream's identification files or they
            # don't have the know-how (or means) to ship their own
            # lsb-release package.
            #
            # This causes users to think there's a bug in system detection
            # tools like neofetch or pfetch when they technically *do*
            # function correctly.
            #
            # Exceptions are made for distributions which are independent,
            # not based on another distribution or follow different
            # standards.
            #
            # This applies only to distributions which follow the standard
            # by shipping unmodified identification files and packages
            # from their respective upstreams.
            if command -v lsb_release; then
                distro=$(lsb_release -sd)

            # Android detection works by checking for the existence of
            # the follow two directories. I don't think there's a simpler
            # method than this.
            elif [ -d /system/app ] && [ -d /system/priv-app ]; then
                distro="Android $(getprop ro.build.version.release)"

            else
                # This used to be a simple '. /etc/os-release' but I believe
                # this is insecure as we blindly executed whatever was in the
                # file. This parser instead simply handles 'key=val', treating
                # the file contents as plain-text.
                while IFS='=' read -r key val; do
                    case $key in
                        PRETTY_NAME) distro=$val ;;
                    esac
                done < /etc/os-release
            fi

            # 'os-release' and 'lsb_release' sometimes add quotes
            # around the distribution name, strip them.
            distro=${distro##[\"\']}
            distro=${distro%%[\"\']}

            # Special cases for (independent) distributions which
            # don't follow any os-release/lsb standards whatsoever.
            command -v crux && distro=$(crux)
            command -v guix && distro='Guix System'

            # Check to see if we're running Bedrock Linux which is
            # very unique. This simply checks to see if the user's
            # PATH contains a Bedrock specific value.
            case $PATH in
                */bedrock/cross/*) distro='Bedrock Linux'
            esac

            # Check to see if Linux is running in Windows 10 under
            # WSL1 (Windows subsystem for Linux [version 1]) and
            # append a string accordingly.
            #
            # If the kernel version string ends in "-Microsoft",
            # we're very likely running under Windows 10 in WSL1.
            if [ "$WSLENV" ]; then
                distro="${distro}${WSLENV+ on Windows 10 [WSL2]}"

            # Check to see if Linux is running in Windows 10 under
            # WSL2 (Windows subsystem for Linux [version 2]) and
            # append a string accordingly.
            #
            # This checks to see if '$WSLENV' is defined. This
            # appends the Windows 10 string even if '$WSLENV' is
            # empty. We only need to check that is has been _exported_.
            elif [ -z "${kernel%%*-Microsoft}" ]; then
                distro="$distro on Windows 10 [WSL1]"
            fi
        ;;

        Darwin*)
            # Parse the SystemVersion.plist file to grab the macOS
            # version. The file is in the following format:
            #
            # <key>ProductVersion</key>
            # <string>10.14.6</string>
            #
            # 'IFS' is set to '<>' to enable splitting between the
            # keys and a second 'read' is used to operate on the
            # next line directly after a match.
            #
            # '_' is used to nullify a field. '_ _ line _' basically
            # says "populate $line with the third field's contents".
            while IFS='<>' read -r _ _ line _; do
                case $line in
                    # Match 'ProductVersion' and read the next line
                    # directly as it contains the key's value.
                    ProductVersion)
                        IFS='<>' read -r _ _ mac_version _
                        break
                    ;;
                esac
            done < /System/Library/CoreServices/SystemVersion.plist

            # Use the ProductVersion to determine which macOS/OS X codename
            # the system has. As far as I'm aware there's no "dynamic" way
            # of grabbing this information.
            case $mac_version in
                10.4*)  distro='Mac OS X Tiger' ;;
                10.5*)  distro='Mac OS X Leopard' ;;
                10.6*)  distro='Mac OS X Snow Leopard' ;;
                10.7*)  distro='Mac OS X Lion' ;;
                10.8*)  distro='OS X Mountain Lion' ;;
                10.9*)  distro='OS X Mavericks' ;;
                10.10*) distro='OS X Yosemite' ;;
                10.11*) distro='OS X El Capitan' ;;
                10.12*) distro='macOS Sierra' ;;
                10.13*) distro='macOS High Sierra' ;;
                10.14*) distro='macOS Mojave' ;;
                10.15*) distro='macOS Catalina' ;;
                *)      distro='macOS' ;;
            esac

            distro="$distro $mac_version"
        ;;

        Haiku)
            # Haiku uses 'uname -v' for version information
            # instead of 'uname -r' which only prints '1'.
            distro=$(uname -sv)
        ;;

        Minix|DragonFly)
            distro="$os $kernel"

            # Minix and DragonFly don't support the escape
            # sequences used, clear the exit trap.
            trap '' EXIT
        ;;

        SunOS)
            # Grab the first line of the '/etc/release' file
            # discarding everything after '('.
            IFS='(' read -r distro _ < /etc/release
        ;;

        OpenBSD*)
            # Show the OpenBSD version type (current if present).
            # kern.version=OpenBSD 6.6-current (GENERIC.MP) ...
            IFS=' =' read -r _ distro openbsd_ver _ <<-EOF
				$(sysctl kern.version)
			EOF

            distro="$distro $openbsd_ver"
        ;;

        *)
            # Catch all to ensure '$distro' is never blank.
            # This also handles the BSDs.
            distro="$os $kernel"
        ;;
    esac
}

get_kernel() {
    case $os in
        # Don't print kernel output on some systems as the
        # OS name includes it.
        *BSD*|Haiku|Minix)
            return
        ;;
    esac

    # '$kernel' is the cached output of 'uname -r'.
    log kernel "$kernel" >&6
}

get_host() {
    case $os in
        Linux*)
            # Despite what these files are called, version doesn't
            # always contain the version nor does name always contain
            # the name.
            read -r name    < /sys/devices/virtual/dmi/id/product_name
            read -r version < /sys/devices/virtual/dmi/id/product_version
            read -r model   < /sys/firmware/devicetree/base/model

            host="$name $version $model"
        ;;

        Darwin*|FreeBSD*|DragonFly*)
            host=$(sysctl -n hw.model)
        ;;

        NetBSD*)
            host=$(sysctl -n machdep.dmi.system-vendor \
                             machdep.dmi.system-product)
        ;;

        OpenBSD*)
            host=$(sysctl -n hw.version)
        ;;

        *BSD*|Minix)
            host=$(sysctl -n hw.vendor hw.product)
        ;;
    esac

    # Turn the host string into an argument list so we can iterate
    # over it and remove OEM strings and other information which
    # shouldn't be displayed.
    #
    # Disable the shellcheck warning for word-splitting
    # as it's safe and intended ('set -f' disables globbing).
    # shellcheck disable=2046,2086
    {
        set -f
        set +f -- $host
        host=
    }

    # Iterate over the host string word by word as a means of stripping
    # unwanted and OEM information from the string as a whole.
    #
    # This could have been implemented using a long 'sed' command with
    # a list of word replacements, however I want to show that something
    # like this is possible in pure sh.
    #
    # This string reconstruction is needed as some OEMs either leave the
    # identification information as "To be filled by OEM", "Default",
    # "undefined" etc and we shouldn't print this to the screen.
    for word; do
        # This works by reconstructing the string by excluding words
        # found in the "blacklist" below. Only non-matches are appended
        # to the final host string.
        case $word in
            To      | [Bb]e      | [Ff]illed | [Bb]y  | O.E.M.  | OEM  |\
            Not     | Applicable | Specified | System | Product | Name |\
            Version | Undefined  | Default   | string | INVALID | �    | os )
                continue
            ;;
        esac

        host="$host$word "
    done

    # '$arch' is the cached output from 'uname -m'.
    log host "${host:-$arch}" >&6
}

get_uptime() {
    # Uptime works by retrieving the data in total seconds and then
    # converting that data into days, hours and minutes using simple
    # math.
    case $os in
        Linux*|Minix*)
            IFS=. read -r s _ < /proc/uptime
        ;;

        Darwin*|*BSD*|DragonFly*)
            s=$(sysctl -n kern.boottime)

            # Extract the uptime in seconds from the following output:
            # [...] { sec = 1271934886, usec = 667779 } Thu Apr 22 12:14:46 2010
            s=${s#*=}
            s=${s%,*}

            # The uptime format from 'sysctl' needs to be subtracted from
            # the current time in seconds.
            s=$(($(date +%s) - s))
        ;;

        Haiku)
            # The boot time is returned in microseconds, convert it to
            # regular seconds.
            s=$(($(system_time) / 1000000))
        ;;

        SunOS)
            # Split the output of 'kstat' on '.' and any white-space
            # which exists in the command output.
            #
            # The output is as follows:
            # unix:0:system_misc:snaptime	14809.906993005
            #
            # The parser extracts:          ^^^^^
            IFS='	.' read -r _ s _ <<-EOF
				$(kstat -p unix:0:system_misc:snaptime)
			EOF
        ;;

        IRIX)
            # Grab the uptime in a pretty format. Usually,
            # 00:00:00 from the 'ps' command.
            t=$(LC_ALL=POSIX ps -o etime= -p 1)

            # Split the pretty output into days or hours
            # based on the uptime.
            case $t in
                *-*)   d=${t%%-*} t=${t#*-} ;;
                *:*:*) h=${t%%:*} t=${t#*:} ;;
            esac

            h=${h#0} t=${t#0}

            # Convert the split pretty fields back into
            # seconds so we may re-convert them to our format.
            s=$((${d:-0}*86400 + ${h:-0}*3600 + ${t%%:*}*60 + ${t#*:}))
        ;;
    esac

    # Convert the uptime from seconds into days, hours and minutes.
    d=$((s / 60 / 60 / 24))
    h=$((s / 60 / 60 % 24))
    m=$((s / 60 % 60))

    # Only append days, hours and minutes if they're non-zero.
    [ "$d" = 0 ] || uptime="${uptime}${d}d "
    [ "$h" = 0 ] || uptime="${uptime}${h}h "
    [ "$m" = 0 ] || uptime="${uptime}${m}m "

    log uptime "${uptime:-0m}" >&6
}

get_pkgs() {
    # This is just a simple wrapper around 'command -v' to avoid
    # spamming '>/dev/null' throughout this function.
    has() { command -v "$1" >/dev/null; }

    # This works by first checking for which package managers are
    # installed and finally by printing each package manager's
    # package list with each package one per line.
    #
    # The output from this is then piped to 'wc -l' to count each
    # line, giving us the total package count of whatever package
    # managers are installed.
    #
    # Backticks are *required* here as '/bin/sh' on macOS is
    # 'bash 3.2' and it can't handle the following:
    #
    # var=$(
    #    code here
    # )
    #
    # shellcheck disable=2006
    packages=`
        case $os in
            Linux*)
                # Commands which print packages one per line.
                has bonsai     && bonsai list
                has crux       && pkginfo -i
                has pacman-key && pacman -Qq
                has dpkg       && dpkg-query -f '.\n' -W
                has rpm        && rpm -qa
                has xbps-query && xbps-query -l
                has apk        && apk info
                has guix       && guix package --list-installed
                has opkg       && opkg list-installed

                # Directories containing packages.
                has kiss       && printf '%s\n' /var/db/kiss/installed/*/
                has brew       && printf '%s\n' "$(brew --cellar)/"*
                has emerge     && printf '%s\n' /var/db/pkg/*/*/
                has pkgtool    && printf '%s\n' /var/log/packages/*
                has eopkg      && printf '%s\n' /var/lib/eopkg/package/*

                # 'nix' requires two commands.
                has nix-store  && {
                    nix-store -q --requisites /run/current-system/sw
                    nix-store -q --requisites ~/.nix-profile
                }
            ;;

            Darwin*)
                # Commands which print packages one per line.
                has pkgin      && pkgin list

                # Directories containing packages.
                has brew       && printf '%s\n' /usr/local/Cellar/*

                # 'port' prints a single line of output to 'stdout'
                # when no packages are installed and exits with
                # success causing a false-positive of 1 package
                # installed.
                #
                # 'port' should really exit with a non-zero code
                # in this case to allow scripts to cleanly handle
                # this behavior.
                has port       && {
                    pkg_list=$(port installed)

                    [ "$pkg_list" = "No ports are installed." ] ||
                        printf '%s\n' "$pkg_list"
                }
            ;;

            FreeBSD*|DragonFly*)
                pkg info
            ;;

            OpenBSD*)
                printf '%s\n' /var/db/pkg/*/
            ;;

            NetBSD*)
                pkg_info
            ;;

            Haiku)
                printf '%s\n' /boot/system/package-links/*
            ;;

            Minix)
                printf '%s\n' /usr/pkg/var/db/pkg/*/
            ;;

            SunOS)
                has pkginfo && pkginfo -i
                has pkg     && pkg list
            ;;

            IRIX)
                versions -b
            ;;
        esac | wc -l
    `

    case $os in
        # IRIX's package manager adds 3 lines of extra
        # output which we must account for here.
        IRIX) packages=$((packages - 3)) ;;
    esac

    [ "$packages" -gt 1 ] && log pkgs "$packages" >&6
}

get_memory() {
    case $os in
        # Used memory is calculated using the following "formula":
        # MemUsed = MemTotal + Shmem - MemFree - Buffers - Cached - SReclaimable
        # Source: https://github.com/KittyKatt/screenFetch/issues/386
        Linux*)
            # Parse the '/proc/meminfo' file splitting on ':' and 'k'.
            # The format of the file is 'key:   000kB' and an additional
            # split is used on 'k' to filter out 'kB'.
            while IFS=':k '  read -r key val _; do
                case $key in
                    MemTotal)
                        mem_used=$((mem_used + val))
                        mem_full=$val
                    ;;

                    Shmem)
                        mem_used=$((mem_used + val))
                    ;;

                    MemFree|Buffers|Cached|SReclaimable)
                        mem_used=$((mem_used - val))
                    ;;
                esac
            done < /proc/meminfo

            mem_used=$((mem_used / 1024))
            mem_full=$((mem_full / 1024))
        ;;

        # Used memory is calculated using the following "formula":
        # (wired + active + occupied) * 4 / 1024
        Darwin*)
            mem_full=$(($(sysctl -n hw.memsize) / 1024 / 1024))

            # Parse the 'vmstat' file splitting on ':' and '.'.
            # The format of the file is 'key:   000.' and an additional
            # split is used on '.' to filter it out.
            while IFS=:. read -r key val; do
                case $key in
                    *' wired'*|*' active'*|*' occupied'*)
                        mem_used=$((mem_used + ${val:-0}))
                    ;;
                esac

            # Using '<<-EOF' is the only way to loop over a command's
            # output without the use of a pipe ('|').
            # This ensures that any variables defined in the while loop
            # are still accessible in the script.
            done <<-EOF
                $(vm_stat)
			EOF

            mem_used=$((mem_used * 4 / 1024))
        ;;

        OpenBSD*)
            mem_full=$(($(sysctl -n hw.physmem) / 1024 / 1024))

            # This is a really simpler parser for 'vmstat' which grabs
            # the used memory amount in a lazy way. 'vmstat' prints 3
            # lines of output with the needed value being stored in the
            # final line.
            #
            # This loop simply grabs the 3rd element of each line until
            # the EOF is reached. Each line overwrites the value of the
            # previous one so we're left with what we wanted. This isn't
            # slow as only 3 lines are parsed.
            while read -r _ _ line _; do
                mem_used=${line%%M}

            # Using '<<-EOF' is the only way to loop over a command's
            # output without the use of a pipe ('|').
            # This ensures that any variables defined in the while loop
            # are still accessible in the script.
            done <<-EOF
                $(vmstat)
			EOF
        ;;

        # Used memory is calculated using the following "formula":
        # mem_full - ((inactive + free + cache) * page_size / 1024)
        FreeBSD*|DragonFly*)
            mem_full=$(($(sysctl -n hw.physmem) / 1024 / 1024))

            # Use 'set --' to store the output of the command in the
            # argument list. POSIX sh has no arrays but this is close enough.
            #
            # Disable the shellcheck warning for word-splitting
            # as it's safe and intended ('set -f' disables globbing).
            # shellcheck disable=2046
            {
                set -f
                set +f -- $(sysctl -n hw.pagesize \
                                      vm.stats.vm.v_inactive_count \
                                      vm.stats.vm.v_free_count \
                                      vm.stats.vm.v_cache_count)
            }

            # Calculate the amount of used memory.
            # $1: hw.pagesize
            # $2: vm.stats.vm.v_inactive_count
            # $3: vm.stats.vm.v_free_count
            # $4: vm.stats.vm.v_cache_count
            mem_used=$((mem_full - (($2 + $3 + $4) * $1 / 1024 / 1024)))
        ;;

        NetBSD*)
            mem_full=$(($(sysctl -n hw.physmem64) / 1024 / 1024))

            # NetBSD implements a lot of the Linux '/proc' filesystem,
            # this uses the same parser as the Linux memory detection.
            while IFS=':k ' read -r key val _; do
                case $key in
                    MemFree)
                        mem_free=$((val / 1024))
                        break
                    ;;
                esac
            done < /proc/meminfo

            mem_used=$((mem_full - mem_free))
        ;;

        Haiku)
            # Read the first line of 'sysinfo -mem' splitting on
            # '(', ' ', and ')'. The needed information is then
            # stored in the 5th and 7th elements. Using '_' "consumes"
            # an element allowing us to proceed to the next one.
            #
            # The parsed format is as follows:
            # 3501142016 bytes free      (used/max  792645632 / 4293787648)
            IFS='( )' read -r _ _ _ _ mem_used _ mem_full <<-EOF
                $(sysinfo -mem)
			EOF

            mem_used=$((mem_used / 1024 / 1024))
            mem_full=$((mem_full / 1024 / 1024))
        ;;

        Minix)
            # Minix includes the '/proc' filesystem though the format
            # differs from Linux. The '/proc/meminfo' file is only a
            # single line with space separated elements and elements
            # 2 and 3 contain the total and free memory numbers.
            read -r _ mem_full mem_free _ < /proc/meminfo

            mem_used=$(((mem_full - mem_free) / 1024))
            mem_full=$(( mem_full / 1024))
        ;;

        SunOS)
            hw_pagesize=$(pagesize)

            # 'kstat' outputs memory in the following format:
            # unix:0:system_pages:pagestotal	1046397
            # unix:0:system_pages:pagesfree		885018
            #
            # This simply uses the first "element" (white-space
            # separated) as the key and the second element as the
            # value.
            #
            # A variable is then assigned based on the key.
            while read -r key val; do
                case $key in
                    *total) pages_full=$val ;;
                    *free)  pages_free=$val ;;
                esac
            done <<-EOF
				$(kstat -p unix:0:system_pages:pagestotal \
                           unix:0:system_pages:pagesfree)
			EOF

            mem_full=$((pages_full * hw_pagesize / 1024 / 1024))
            mem_free=$((pages_free * hw_pagesize / 1024 / 1024))
            mem_used=$((mem_full - mem_free))
        ;;

        IRIX)
            # Read the memory information from the 'top' command. Parse
            # and split each line until we reach the line starting with
            # "Memory".
            #
            # Example output: Memory: 160M max, 147M avail, .....
            while IFS=' :' read -r label mem_full _ mem_free _; do
                case $label in
                    Memory)
                        mem_full=${mem_full%M}
                        mem_free=${mem_free%M}
                        break
                    ;;
                esac
            done <<-EOF
                $(top -n)
			EOF

            mem_used=$((mem_full - mem_free))
        ;;
    esac

    log memory "${mem_used:-?}M / ${mem_full:-?}M" >&6
}

get_wm() {
    case $os in
        # Don't display window manager on macOS.
        Darwin*) ;;

        *)
            # xprop can be used to grab the window manager's properties
            # which contains the window manager's name under '_NET_WM_NAME'.
            #
            # The upside to using 'xprop' is that you don't need to hardcode
            # a list of known window manager names. The downside is that
            # not all window managers conform to setting the '_NET_WM_NAME'
            # atom..
            #
            # List of window managers which fail to set the name atom:
            # catwm, fvwm, dwm, 2bwm, monster, wmaker and sowm [mine! ;)].
            #
            # The final downside to this approach is that it does _not_
            # support Wayland environments. The only solution which supports
            # Wayland is the 'ps' parsing mentioned below.
            #
            # A more naive implementation is to parse the last line of
            # '~/.xinitrc' to extract the second white-space separated
            # element.
            #
            # The issue with an approach like this is that this line data
            # does not always equate to the name of the window manager and
            # could in theory be _anything_.
            #
            # This also fails when the user launches xorg through a display
            # manager or other means.
            #
            #
            # Another naive solution is to parse 'ps' with a hardcoded list
            # of window managers to detect the current window manager (based
            # on what is running).
            #
            # The issue with this approach is the need to hardcode and
            # maintain a list of known window managers.
            #
            # Another issue is that process names do not always equate to
            # the name of the window manager. False-positives can happen too.
            #
            # This is the only solution which supports Wayland based
            # environments sadly. It'd be nice if some kind of standard were
            # established to identify Wayland environments.
            #
            # pfetch's goal is to remain _simple_, if you'd like a "full"
            # implementation of window manager detection use 'neofetch'.
            #
            # Neofetch use a combination of 'xprop' and 'ps' parsing to
            # support all window managers (including non-conforming and
            # Wayland) though it's a lot more complicated!

            # Don't display window manager if X isn't running.
            [ "$DISPLAY" ] || return

            # This is a two pass call to xprop. One call to get the window
            # manager's ID and another to print its properties.
            command -v xprop && {
                # The output of the ID command is as follows:
                # _NET_SUPPORTING_WM_CHECK: window id # 0x400000
                #
                # To extract the ID, everything before the last space
                # is removed.
                id=$(xprop -root -notype _NET_SUPPORTING_WM_CHECK)
                id=${id##* }

                # The output of the property command is as follows:
                # _NAME 8t
                # _NET_WM_PID = 252
                # _NET_WM_NAME = "bspwm"
                # _NET_SUPPORTING_WM_CHECK: window id # 0x400000
                # WM_CLASS = "wm", "Bspwm"
                #
                # To extract the name, everything before '_NET_WM_NAME = \"'
                # is removed and everything after the next '"' is removed.
                wm=$(xprop -id "$id" -notype -len 25 -f _NET_WM_NAME 8t)
            }

            # Handle cases of a window manager _not_ populating the
            # '_NET_WM_NAME' atom. Display nothing in this case.
            case $wm in
                *'_NET_WM_NAME = '*)
                    wm=${wm##*_NET_WM_NAME = \"}
                    wm=${wm%%\"*}
                ;;

                *)
                    # Fallback to checking the process list
                    # for the select few window managers which
                    # don't set '_NET_WM_NAME'.
                    while read -r ps_line; do
                        case $ps_line in
                            *catwm*)     wm=catwm ;;
                            *fvwm*)      wm=fvwm ;;
                            *dwm*)       wm=dwm ;;
                            *2bwm*)      wm=2bwm ;;
                            *monsterwm*) wm=monsterwm ;;
                            *wmaker*)    wm='Window Maker' ;;
                            *sowm*)      wm=sowm ;;
                        esac
                    done <<-EOF
                        $(ps x)
					EOF
                ;;
            esac
        ;;
    esac

    log wm "$wm" >&6
}


get_de() {
    # This only supports Xorg related desktop environments though
    # this is fine as knowing the desktop environment on Windows,
    # macOS etc is useless (they'll always report the same value).
    #
    # Display the value of '$XDG_CURRENT_DESKTOP', if it's empty,
    # display the value of '$DESKTOP_SESSION'.
    log de "${XDG_CURRENT_DESKTOP:-$DESKTOP_SESSION}" >&6
}

get_shell() {
    # Display the basename of the '$SHELL' environment variable.
    log shell "${SHELL##*/}" >&6
}

get_editor() {
    # Display the value of '$VISUAL', if it's empty, display the
    # value of '$EDITOR'.
    log editor "${VISUAL:-$EDITOR}" >&6
}

get_palette() {
    # Print the first 8 terminal colors. This uses the existing
    # sequences to change text color with a sequence prepended
    # to reverse the foreground and background colors.
    #
    # This allows us to save hardcoding a second set of sequences
    # for background colors.
    palette="[7m$c1 $c1 $c2 $c2 $c3 $c3 $c4 $c4 $c5 $c5 $c6 $c6 [m"

    # Print the palette with a new-line before and afterwards.
    printf '\n' >&6
    log "$palette
        " " " >&6
}

get_ascii() {
    # This is a simple function to read the contents of
    # an ascii file from 'stdin'. It allows for the use
    # of '<<-EOF' to prevent the break in indentation in
    # this source code.
    #
    # This function also sets the text colors according
    # to the ascii color.
    read_ascii() {
        # 'PF_COL1': Set the info name color according to ascii color.
        # 'PF_COL3': Set the title color to some other color. ¯\_(ツ)_/¯
        PF_COL1=${PF_COL1:-${1:-7}}
        PF_COL3=${PF_COL3:-$((${1:-7}%8+1))}

        # POSIX sh has no 'var+=' so 'var=${var}append' is used. What's
        # interesting is that 'var+=' _is_ supported inside '$(())'
        # (arithmetic) though there's no support for 'var++/var--'.
        #
        # There is also no $'\n' to add a "literal"(?) newline to the
        # string. The simplest workaround being to break the line inside
        # the string (though this has the caveat of breaking indentation).
        while IFS= read -r line; do
            ascii="$ascii$line
"
        done
    }

    # This checks for ascii art in the following order:
    # '$1':        Argument given to 'get_ascii()' directly.
    # '$PF_ASCII': Environment variable set by user.
    # '$distro':   The detected distribution name.
    # '$os':       The name of the operating system/kernel.
    #
    # NOTE: Each ascii art below is indented using tabs, this
    #       allows indentation to continue naturally despite
    #       the use of '<<-EOF'.
    case ${1:-${PF_ASCII:-${distro:-$os}}} in
        [Aa]lpine*)
            read_ascii 4 <<-EOF
				${c4}   /\\ /\\
				  /${c7}/ ${c4}\\  \\
				 /${c7}/   ${c4}\\  \\
				/${c7}//    ${c4}\\  \\
				${c7}//      ${c4}\\  \\
				         ${c4}\\
			EOF
        ;;

        [Aa]ndroid*)
            read_ascii 2 <<-EOF
				${c2}  ;,           ,;
				${c2}   ';,.-----.,;'
				${c2}  ,'           ',
				${c2} /    O     O    \\
				${c2}|                 |
				${c2}'-----------------'
			EOF
        ;;

        [Aa]rch*)
            read_ascii 4 <<-EOF
				${c6}       /\\
				${c6}      /  \\
				${c6}     /\\   \\
				${c4}    /      \\
				${c4}   /   ,,   \\
				${c4}  /   |  |  -\\
				${c4} /_-''    ''-_\\
			EOF
        ;;

        [Aa]rco*)
            read_ascii 4 <<-EOF
				${c4}      /\\
				${c4}     /  \\
				${c4}    / /\\ \\
				${c4}   / /  \\ \\
				${c4}  / /    \\ \\
				${c4} / / _____\\ \\
				${c4}/_/  \`----.\\_\\
			EOF
        ;;

        [Aa]rtix*)
            read_ascii 6 <<-EOF
				${c4}      /\\
				${c4}     /  \\
				${c4}    /\`'.,\\
				${c4}   /     ',
				${c4}  /      ,\`\\
				${c4} /   ,.'\`.  \\
				${c4}/.,'\`     \`'.\\
			EOF
        ;;

        [Bb]edrock*)
            read_ascii 4 <<-EOF
				${c7}__
				${c7}\\ \\___
				${c7} \\  _ \\
				${c7}  \\___/
			EOF
        ;;

        [Cc]ent[Oo][Ss]*)
            read_ascii 5 <<-EOF
				${c2} ____${c3}^${c5}____
				${c2} |\\  ${c3}|${c5}  /|
				${c2} | \\ ${c3}|${c5} / |
				${c5}<---- ${c4}---->
				${c4} | / ${c2}|${c3} \\ |
				${c4} |/__${c2}|${c3}__\\|
				${c2}     v
			EOF
        ;;

        [Dd]ebian*)
            read_ascii 1 <<-EOF
				${c1}  _____
				${c1} /  __ \\
				${c1}|  /    |
				${c1}|  \\___-
				${c1}-_
				${c1}  --_
			EOF
        ;;

        [Dd]ragon[Ff]ly*)
            read_ascii 1 <<-EOF
				    ,${c1}_${c7},
				 ('-_${c1}|${c7}_-')
				  >--${c1}|${c7}--<
				 (_-'${c1}|${c7}'-_)
				     ${c1}|
				     ${c1}|
				     ${c1}|
			EOF
        ;;

        [Ee]lementary*)
            read_ascii <<-EOF
				${c7}  _______
				${c7} / ____  \\
				${c7}/  |  /  /\\
				${c7}|__\\ /  / |
				${c7}\\   /__/  /
				 ${c7}\\_______/
			EOF
        ;;

        [Ee]ndeavour*)
            read_ascii 4 <<-EOF
    				      ${c1}/${c4}\\
				    ${c1}/${c4}/  \\${c6}\\
				   ${c1}/${c4}/    \\ ${c6}\\
				 ${c1}/ ${c4}/     _) ${c6})
				${c1}/_${c4}/___-- ${c6}__-
				 ${c6}/____--
			EOF
        ;;

        [Ff]edora*)
            read_ascii 4 <<-EOF
				${c7}      _____
				     /   __)${c4}\\${c7}
				     |  /  ${c4}\\ \\${c7}
				  ${c4}__${c7}_|  |_${c4}_/ /${c7}
				 ${c4}/ ${c7}(_    _)${c4}_/${c7}
				${c4}/ /${c7}  |  |
				${c4}\\ \\${c7}__/  |
				 ${c4}\\${c7}(_____/
			EOF
        ;;

        [Ff]ree[Bb][Ss][Dd]*)
            read_ascii 1 <<-EOF
				${c1}/\\,-'''''-,/\\
				${c1}\\_)       (_/
				${c1}|           |
				${c1}|           |
				 ${c1};         ;
				  ${c1}'-_____-'
			EOF
        ;;

        [Gg]entoo*)
            read_ascii 5 <<-EOF
				${c5} _-----_
				${c5}(       \\
				${c5}\\    0   \\
				${c7} \\        )
				${c7} /      _/
				${c7}(     _-
				${c7}\\____-
			EOF
        ;;

        [Gg][Nn][Uu]*)
            read_ascii 3 <<-EOF
				${c2}    _-\`\`-,   ,-\`\`-_
				${c2}  .'  _-_|   |_-_  '.
				${c2}./    /_._   _._\\    \\.
				${c2}:    _/_._\`:'_._\\_    :
				${c2}\\:._/  ,\`   \\   \\ \\_.:/
				${c2}   ,-';'.@)  \\ @) \\
				${c2}   ,'/'  ..- .\\,-.|
				${c2}   /'/' \\(( \\\` ./ )
				${c2}    '/''  \\_,----'
				${c2}      '/''   ,;/''
				${c2}         \`\`;'
			EOF
        ;;

        [Gg]uix[Ss][Dd]*|[Gg]uix*)
            read_ascii 3 <<-EOF
				${c3}|.__          __.|
				${c3}|__ \\        / __|
				   ${c3}\\ \\      / /
				    ${c3}\\ \\    / /
				     ${c3}\\ \\  / /
				      ${c3}\\ \\/ /
				       ${c3}\\__/
			EOF
        ;;

        [Hh]aiku*)
            read_ascii 3 <<-EOF
				${c3}       ,^,
				 ${c3}     /   \\
				${c3}*--_ ;     ; _--*
				${c3}\\   '"     "'   /
				 ${c3}'.           .'
				${c3}.-'"         "'-.
				 ${c3}'-.__.   .__.-'
				       ${c3}|_|
			EOF
        ;;

        [Hh]yperbola*)
            read_ascii <<-EOF
				${c7}    |\`__.\`/
				   ${c7} \____/
				   ${c7} .--.
				  ${c7} /    \\
				 ${c7} /  ___ \\
				 ${c7}/ .\`   \`.\\
				${c7}/.\`      \`.\\
			EOF
        ;;

        [Ii][Rr][Ii][Xx]*)
            read_ascii 1 <<-EOF
				${c1} __
				${c1} \\ \\   __
				${c1}  \\ \\ / /
				${c1}   \\ v /
				${c1}   / . \\
				${c1}  /_/ \\ \\
				${c1}       \\_\\
			EOF
        ;;

        [Kk][Dd][Ee]*[Nn]eon*)
            read_ascii 6 <<-EOF
				${c7}   .${c6}__${c7}.${c6}__${c7}.
				${c6}  /  _${c7}.${c6}_  \\
				${c6} /  /   \\  \\
				${c7} . ${c6}|  ${c7}O${c6}  | ${c7}.
				${c6} \\  \\_${c7}.${c6}_/  /
				${c6}  \\${c7}.${c6}__${c7}.${c6}__${c7}.${c6}/
			EOF
        ;;

        [Ll]inux*[Ll]ite*|[Ll]ite*)
            read_ascii 3 <<-EOF
				${c3}   /\\
				${c3}  /  \\
				${c3} / ${c7}/ ${c3}/
			${c3}> ${c7}/ ${c3}/
				${c3}\\ ${c7}\\ ${c3}\\
				 ${c3}\\_${c7}\\${c3}_\\
				${c7}    \\
			EOF
        ;;

        [Ll]inux*[Mm]int*|[Mm]int)
            read_ascii 2 <<-EOF
				${c2} ___________
				${c2}|_          \\
				  ${c2}| ${c7}| _____ ${c2}|
				  ${c2}| ${c7}| | | | ${c2}|
				  ${c2}| ${c7}| | | | ${c2}|
				  ${c2}| ${c7}\\__${c7}___/ ${c2}|
				  ${c2}\\_________/
			EOF
        ;;


        [Ll]inux*)
            read_ascii 4 <<-EOF
				${c4}    ___
				   ${c4}(${c7}.. ${c4}|
				   ${c4}(${c5}<> ${c4}|
				  ${c4}/ ${c7}__  ${c4}\\
				 ${c4}( ${c7}/  \\ ${c4}/|
				${c5}_${c4}/\\ ${c7}__)${c4}/${c5}_${c4})
				${c5}\/${c4}-____${c5}\/
			EOF
        ;;

        [Mm]ac[Oo][Ss]*|[Dd]arwin*)
            read_ascii 1 <<-EOF
				${c1}       .:'
				${c1}    _ :'_
				${c2} .'\`_\`-'_\`\`.
				${c2}:________.-'
				${c3}:_______:
				${c4} :_______\`-;
				${c5}  \`._.-._.'
			EOF
        ;;

        [Mm]ageia*)
            read_ascii 2 <<-EOF
				${c6}   *
				${c6}    *
				${c6}   **
				${c7} /\\__/\\
				${c7}/      \\
				${c7}\\      /
				${c7} \\____/
			EOF
        ;;

        [Mm]anjaro*)
            read_ascii 2 <<-EOF
				${c2}||||||||| ||||
				${c2}||||||||| ||||
				${c2}||||      ||||
				${c2}|||| |||| ||||
				${c2}|||| |||| ||||
				${c2}|||| |||| ||||
				${c2}|||| |||| ||||
			EOF
        ;;

        [Mm]inix*)
            read_ascii 4 <<-EOF
				${c4} ,,        ,,
				${c4};${c7},${c4} ',    ,' ${c7},${c4};
				${c4}; ${c7}',${c4} ',,' ${c7},'${c4} ;
				${c4};   ${c7}',${c4}  ${c7},'${c4}   ;
				${c4};  ${c7};, '' ,;${c4}  ;
				${c4};  ${c7};${c4};${c7}',,'${c4};${c7};${c4}  ;
				${c4}', ${c7};${c4};;  ;;${c7};${c4} ,'
				 ${c4} '${c7};${c4}'    '${c7};${c4}'
			EOF
        ;;

        [Mm][Xx]*)
            read_ascii <<-EOF
				${c7}    \\\\  /
				 ${c7}    \\\\/
				 ${c7}     \\\\
				 ${c7}  /\\/ \\\\
				${c7}  /  \\  /\\
				${c7} /    \\/  \\
			${c7}/__________\\
			EOF
        ;;

        [Nn]et[Bb][Ss][Dd]*)
            read_ascii 3 <<-EOF
				${c7}\\\\${c3}\`-______,----__
				${c7} \\\\        ${c3}__,---\`_
				${c7}  \\\\       ${c3}\`.____
				${c7}   \\\\${c3}-______,----\`-
				${c7}    \\\\
				${c7}     \\\\
				${c7}      \\\\
			EOF
        ;;

        [Nn]ix[Oo][Ss]*)
            read_ascii 4 <<-EOF
				${c4}  \\\\  \\\\ //
				${c4} ==\\\\__\\\\/ //
				${c4}   //   \\\\//
				${c4}==//     //==
				${c4} //\\\\___//
				${c4}// /\\\\  \\\\==
				${c4}  // \\\\  \\\\
			EOF
        ;;

        [Oo]pen[Bb][Ss][Dd]*)
            read_ascii 3 <<-EOF
				${c3}      _____
				${c3}    \\-     -/
				${c3} \\_/         \\
				${c3} |        ${c7}O O${c3} |
				${c3} |_  <   )  3 )
				${c3} / \\         /
				 ${c3}   /-_____-\\
			EOF
        ;;

        [Oo]pen[Ss][Uu][Ss][Ee]*[Tt]umbleweed*)
            read_ascii 2 <<-EOF
				${c2}  _____   ______
				${c2} / ____\\ / ____ \\
				${c2}/ /    \`/ /    \\ \\
				${c2}\\ \\____/ /,____/ /
				${c2} \\______/ \\_____/
			EOF
        ;;

        [Oo]pen[Ss][Uu][Ss][Ee]*|[Oo]pen*SUSE*|SUSE*|suse*)
            read_ascii 2 <<-EOF
				${c2}  _______
				${c2}__|   __ \\
				${c2}     / .\\ \\
				${c2}     \\__/ |
				${c2}   _______|
				${c2}   \\_______
				${c2}__________/
			EOF
        ;;

        [Oo]pen[Ww]rt*)
            read_ascii 1 <<-EOF
				${c1} _______
				${c1}|       |.-----.-----.-----.
				${c1}|   -   ||  _  |  -__|     |
				${c1}|_______||   __|_____|__|__|
				${c1} ________|__|    __
				${c1}|  |  |  |.----.|  |_
				${c1}|  |  |  ||   _||   _|
				${c1}|________||__|  |____|
			EOF
        ;;

        [Pp]arabola*)
            read_ascii 5 <<-EOF
				${c5}  __ __ __  _
				${c5}.\`_//_//_/ / \`.
				${c5}          /  .\`
				${c5}         / .\`
				${c5}        /.\`
				${c5}       /\`
			EOF
        ;;

        [Pp]op!_[Oo][Ss]*)
            read_ascii 6 <<-EOF
				${c6}______
				${c6}\\   _ \\        __
				 ${c6}\\ \\ \\ \\      / /
				  ${c6}\\ \\_\\ \\    / /
				   ${c6}\\  ___\\  /_/
				   ${c6} \\ \\    _
				  ${c6} __\\_\\__(_)_
				  ${c6}(___________)
			EOF
        ;;

        [Pp]ure[Oo][Ss]*)
            read_ascii <<-EOF
				${c7} _____________
				${c7}|  _________  |
				${c7}| |         | |
				${c7}| |         | |
				${c7}| |_________| |
				${c7}|_____________|
			EOF
        ;;

        [Rr]aspbian*)
            read_ascii 1 <<-EOF
				${c1}  __  __
				${c1} (_\\)(/_)
				${c2} (_(__)_)
				${c2}(_(_)(_)_)
				${c2} (_(__)_)
				${c2}   (__)
			EOF
        ;;

        [Ss]lackware*)
            read_ascii 4 <<-EOF
				${c4}   ________
				${c4}  /  ______|
				${c4}  | |______
				${c4}  \\______  \\
				${c4}   ______| |
				${c4}| |________/
				${c4}|____________
			EOF
        ;;

        [Ss]un[Oo][Ss]|[Ss]olaris*)
            read_ascii 3 <<-EOF
				${c3}       .   .;   .
				${c3}   .   :;  ::  ;:   .
				${c3}   .;. ..      .. .;.
				${c3}..  ..             ..  ..
				${c3} .;,                 ,;.
			EOF
        ;;

        [Uu]buntu*)
            read_ascii 3 <<-EOF
				${c3}         _
				${c3}     ---(_)
				${c3} _/  ---  \\
				${c3}(_) |   |
				 ${c3} \\  --- _/
				    ${c3} ---(_)
			EOF
        ;;

        [Vv]oid*)
            read_ascii 2 <<-EOF
				${c2}    _______
				${c2} _ \\______ -
				${c2}| \\  ___  \\ |
				${c2}| | /   \ | |
				${c2}| | \___/ | |
				${c2}| \\______ \\_|
				${c2} -_______\\
			EOF
        ;;

        *)
            # On no match of a distribution ascii art, this function calls
            # itself again, this time to look for a more generic OS related
            # ascii art (KISS Linux -> Linux).
            [ "$1" ] || {
                get_ascii "$os"
                return
            }

            printf 'error: %s is not currently supported.\n' "$os" >&6
            printf 'error: Open an issue for support to be added.\n' >&6
            exit 1
        ;;
    esac

    # Store the "width" (longest line) and "height" (number of lines)
    # of the ascii art for positioning. This script prints to the screen
    # *almost* like a TUI does. It uses escape sequences to allow dynamic
    # printing of the information through user configuration.
    #
    # Iterate over each line of the ascii art to retrieve the above
    # information. The 'sed' is used to strip '[3Xm' color codes from
    # the ascii art so they don't affect the width variable.
    while read -r line; do
        ascii_height=$((${ascii_height:-0} + 1))

        # This was a ternary operation but they aren't supported in
        # Minix's shell.
        [ "${#line}" -gt "${ascii_width:-0}" ] &&
            ascii_width=${#line}

    # Using '<<-EOF' is the only way to loop over a command's
    # output without the use of a pipe ('|').
    # This ensures that any variables defined in the while loop
    # are still accessible in the script.
    done <<-EOF
 		$(printf %s "$ascii" | sed 's/\[3.m//g')
	EOF

    # Add a gap between the ascii art and the information.
    ascii_width=$((ascii_width + 4))

    # Print the ascii art and position the cursor back where we
    # started prior to printing it.
    # '[1m':   Print the ascii in bold.
    # '[m':    Clear bold.
    # '[%sA':  Move the cursor up '$ascii_height' amount of lines.
    printf '[1m%s[m[%sA' "$ascii" "$ascii_height" >&6
}

main() {
    [ "$1" = --version ] && {
        printf 'pfetch 0.7.0\n'
        exit
    }

    # Hide 'stderr' unless the first argument is '-v'. This saves
    # polluting the script with '2>/dev/null'.
    [ "$1" = -v ] || exec 2>/dev/null

    # Hide 'stdout' and selectively print to it using '>&6'.
    # This gives full control over what it displayed on the screen.
    exec 6>&1 >/dev/null

    # Allow the user to execute their own script and modify or
    # extend pfetch's behavior.
    # shellcheck source=/dev/null
    . "${PF_SOURCE:-/dev/null}" ||:

    # Ensure that the 'TMPDIR' is writable as heredocs use it and
    # fail without the write permission. This was found to be the
    # case on Android where the temporary directory requires root.
    [ -w "${TMPDIR:-/tmp}" ] || export TMPDIR=~

    # Generic color list.
    # Disable warning about unused variables.
    # shellcheck disable=2034
    {
        c1='[31m'; c2='[32m'
        c3='[33m'; c4='[34m'
        c5='[35m'; c6='[36m'
        c7='[37m'; c8='[38m'
    }

    # Avoid text-wrapping from wrecking the program output.
    #
    # Some terminals don't support these sequences, nor do they
    # silently conceal them if they're printed resulting in
    # partial sequences being printed to the terminal!
    [ "$TERM" = dumb ]   ||
    [ "$TERM" = minix ]  ||
    [ "$TERM" = cons25 ] || {
        # Disable line-wrapping.
        printf '[?7l' >&6

        # Enable line-wrapping again on exit.
        trap 'printf [?7h >&6' EXIT
    }

    # Store the output of 'uname' to avoid calling it multiple times
    # throughout the script. 'read <<EOF' is the simplest way of reading
    # a command into a list of variables.
    read -r os kernel arch <<-EOF
		$(uname -srm)
	EOF

    # Always run 'get_os' for the purposes of detecting which ascii
    # art to display.
    get_os

    # Allow the user to specify the order and inclusion of information
    # functions through the 'PF_INFO' environment variable.
    # shellcheck disable=2086
    {
        # Disable globbing and set the positional parameters to the
        # contents of 'PF_INFO'.
        set -f
        set +f -- ${PF_INFO-ascii title os host kernel uptime pkgs memory}

        # Iterate over the info functions to determine the lengths of the
        # "info names" for output alignment. The option names and subtitles
        # match 1:1 so this is thankfully simple.
        for info; do
            command -v "get_$info" >/dev/null || continue

            # This was a ternary operation but they aren't supported in
            # Minix's shell.
            [ "${#info}" -gt "${info_length:-0}" ] &&
                info_length=${#info}
        done

        # Add an additional space of length to act as a gap.
        info_length=$((info_length + 1))

        # Iterate over the above list and run any existing "get_" functions.
        for info; do "get_$info"; done
    }

    # Position the cursor below both the ascii art and information lines
    # according to the height of both. If the information exceeds the ascii
    # art in height, don't touch the cursor (0/unset), else move it down
    # N lines.
    #
    # This was a ternary operation but they aren't supported in Minix's shell.
    [ "${info_height:-0}" -lt "${ascii_height:-0}" ] &&
        cursor_pos=$((ascii_height - info_height))

    # Print '$cursor_pos' amount of newlines to correctly position the
    # cursor. This used to be a 'printf $(seq X X)' however 'seq' is only
    # typically available (by default) on GNU based systems!
    while [ "${i:=0}" -le "${cursor_pos:-0}" ]; do
        printf '\n'
        i=$((i + 1))
    done >&6
}

main "$@"
