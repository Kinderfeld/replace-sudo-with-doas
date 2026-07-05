#!/bin/sh
#
# Copyright waiver for <https://github.com/Kinderfeld/replace-sudo>
#
# I dedicate any and all copyright interest in this software to the
# public domain. I make this dedication for the benefit of the public at
# large and to the detriment of my heirs and successors. I intend this
# dedication to be an overt act of relinquishment in perpetuity of all
# present and future rights to this software under copyright law.
#
# To the best of my knowledge and belief, my contributions are either
# originally authored by me or are derived from prior works which I have
# verified are also in the public domain and are not subject to claims
# of copyright by other parties.
#
# To the best of my knowledge and belief, no individual, business,
# organization, government, or other entity has any copyright interest
# in my contributions, and I affirm that I will not make contributions
# that are otherwise encumbered.

# Disable unicode.
LC_ALL="C"
LANG="C"

sudo_to_ignore()
{
    printf "[<==] Adding 'sudo' to ignored packages...\n"

    mkdir -p /etc/xbps.d
    if [ ! -e /etc/xbps.d/ignore.conf ] || ! grep -q "^ignorepkg=sudo" /etc/xbps.d/ignore.conf; then
        echo "ignorepkg=sudo" >> /etc/xbps.d/ignore.conf
    fi
}

remove_sudo()
{
    printf "[<==] Removing 'sudo'...\n"

    case "$1" in
        alpine)  apk del sudo                                     ;;
        arch)    pacman -R sudo                                   ;;
        debian)  apt remove sudo                                  ;;
        freebsd) pkg remove sudo                                  ;;
        netbsd)  pkgin remove sudo                                ;;
        openbsd) pkg_delete sudo                                  ;;
        void)    sudo_to_ignore && xbps-remove sudo               ;;
        *)       printf "[!] Unsupported OS: '%s'\n" "$1"; exit 1 ;;
    esac
}

install_doas()
{
    printf "[<==] Installing 'doas'...\n"

    case "$1" in
        alpine)  apk add doas             ;;
        arch)    pacman -S doas           ;;
        debian)  apt install doas         ;;
        freebsd) pkg install doas         ;;
        netbsd)  pkgin install doas       ;;
        openbsd) pkg_add doas             ;;
        void)    xbps-install -S opendoas ;;
    esac
}

configure_doas()
{
    printf "[<==] Configuring 'doas'...\n"

    config="permit persist setenv {PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin} :wheel"

    case "$1" in
        freebsd) echo "${config}" > /usr/local/etc/doas.conf || echo "${config}" > /etc/doas.conf ;;
        netbsd)  echo "${config}" > /usr/pkg/etc/doas.conf || echo "${config}" > /etc/doas.conf ;;
        *)       echo "${config}" > /etc/doas.conf ;;
    esac

    ln -sf "$(command -v doas)" /usr/bin/sudo
}

configure_mdo()
{
    printf "[<==] Configuring 'mdo'...\n"

    config="uid=1001>uid=0,gid=*,+gid=*"

    kldload mac_do
    sysctl security.mac.do.enabled
    sysctl security.mac.do.rules="$config"
    echo 'mac_do_load="YES"' >> /boot/loader.conf
}

root_check()
{
    [ "$(id -u)" -ne 0 ] && {
        printf "[!] This script must be run with root privileges.\n" >&2
        exit 1
    }
}

main()
{
    printf "[*] Starting 'sudo' replacement...\n"

    printf "[==>] Enter your OS family [Debian, Arch, Alpine, Void, FreeBSD, OpenBSD, NetBSD]: "
    read -r os; os=$(printf "%s" "$os" | tr '[:upper:]' '[:lower:]')

    if [ "$os" = "freebsd" ]; then
        printf "[==>] FreeBSD supports 'mdo' via mac_do. Use it instead of 'doas'? [y/N]: "
        read -r choice

        case "$choice" in
            [Yy]|[Yy][Ee][Ss])
                remove_sudo "$os"
                configure_mdo
                printf "[*] Success! 'mdo' has been configured.\n"
                return
                ;;
        esac
    fi

    remove_sudo "$os"
    install_doas "$os"
    configure_doas "$os"

    printf "[*] Success!\n"
}

root_check
main

