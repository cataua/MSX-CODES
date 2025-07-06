#!/bin/bash --
# rebuild-all.sh: rebuilds "clean" zip and also constructs roms
#
# requires figlet, zip, and everything else rebuild.sh requires
#
# if you want to build headless and have Xfvb and xinit and your openmsx speaks X11, do:
#
#   xinit "$(command -v bash)" ./rebuild-all.sh -- "$( command -v Xvfb )" :99 -cc 4 -screen 0 640x480x16
#
# if you want visible but single-window GUI parts of the build and have Xephyr, xinit, xterm and
# X11 bitmap fonts, do:
#
#   ( xinit "$(command -v bash)" -c 'bash ./rebuild-all.sh 2>&1 | '`: \
#        `' tee >( LC_ALL=C xterm -fn 6x12 -fullscreen -g $(( 640/6 ))x$(( 480/12 )) +sb -b 0 '`: \
#        `' -e cat <( cat /dev/fd/0 ) )' -- "$( command -v Xephyr )" :99 -screen 640x480 )
#
# in both cases change :99 to an available X11 display if :99 is not available.

rebuild_all() {
    figlet -v | head -1 | fgrep FIGlet &&
        (
            rm -rvf pirate-multi-example.rom pirate-multi-clean pirate-multi-clean.zip ||
                (
                    sleep 1 &&
                        rm -rvf pirate-multi-example.rom pirate-multi-clean pirate-multi-clean.zip
                )
        ) &&
        mkdir pirate-multi-clean &&
        cp -v rebuild.sh rebuild-all.sh apply_ips.py basld.py boot.rom menu.asc numdebug.asc numtests.asc slot-* pirate-multi-clean &&
        (
            (
                figlet -f mini 'pirate multi' &&
                    figlet -f banner 8xxx
            ) | tr '#' '"'
        ) | tee pirate-multi-clean/banner.txt &&
        (
            cd pirate-multi-clean &&
                bash rebuild.sh
        ) &&
        mv -v pirate-multi-clean/pirate-multicart.rom pirate-multi-example.rom &&
        (
            rm -v pirate-multi-clean/*.zip pirate-multi-clean/slot-* pirate-multi-clean/all-slot*rom pirate-multi-clean/pirate*rom ||
                (
                    sleep 1 &&
                        rm -v pirate-multi-clean/*.zip pirate-multi-clean/slot-* pirate-multi-clean/all-slot*rom pirate-multi-clean/pirate*rom ||
                            (
                                sleep 1 &&
                                    rm -v pirate-multi-clean/*.zip pirate-multi-clean/slot-* pirate-multi-clean/all-slot*rom pirate-multi-clean/pirate*rom
                            )
                )
        ) &&
        zip -jm9r pirate-multi-clean{,} &&
        (
            rm -rvf pirate-multi-clean ||
                (
                    sleep 1 &&
                        rm -rvf pirate-multi-clean ||
                            (
                                sleep 1 &&
                                    rm -rvf pirate-multi-clean
                            )
                )
        ) &&
        bash rebuild.sh
    exit $?
}

rebuild_all "$@"; exit $?