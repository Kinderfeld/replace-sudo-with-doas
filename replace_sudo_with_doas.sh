#!/usr/bin/env sh
#
# Copyright waiver for <https://github.com/Kinderfeld/replace-sudo-with-doas
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

remove_sudo()
{
    printf "[<==] Removing 'sudo'...\n"

    [ "$1" == "debian" ] && apt remove sudo
    [ "$1" == "arch" ] && pacman -R sudo
    [ "$1" == "alpine" ] && apk del sudo
    [ "$1" == "freebsd" ] && pkg remove sudo
}

install_doas()
{
    printf "[<==] Installing 'doas'...\n"

    [ "$1" == "debian" ] && apt install doas
    [ "$1" == "arch" ] && pacman -S doas
    [ "$1" == "alpine"] && apk add doas
    [ "$1" == "freebsd" ] && pkg install doas
}

configure_doas()
{
    printf "[<==] Configuring 'doas'...\n"

    config="permit persist setenv {PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin} :wheel" 
    echo "${config}" > /etc/doas.conf

    ln -s $(which doas) /usr/bin/sudo
}

main()
{
    printf "[*] Starting 'sudo' replacement..\n"

    printf "[==>] Enter your OS family [debian, arch, alpine, freebsd]: "
    read os

    remove_sudo "${os}"
    install_doas "${os}"
    configure_doas

    printf "[*] Success!\n"
}

main

