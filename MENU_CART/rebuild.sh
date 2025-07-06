#!/bin/bash --
#
# What if you have a 512KB multicart split into DIP-selectable 128KB sections that supports the Konami4 mapper?
# What if you want to put multiple games in there, and you don't mind if they are selected for mainly technical reasons?
# What if you don't mind if you only get a single BASIC game in there?
# What if you don't mind a slow and ugly text-only menu system?
# What if you don't mind wasting some space idn your ROM ?
# What if you don't mind a brittle build process full of bugs?
#
# If the answer to all of the above was "yeah, sure, why not..." then this script can help you build such a multicart ROM image!
#
#                           ...
# This script rebuilds the 8xxx multicart from parts:
#
# - slot-?0-*-7k.asc
#     These are BASIC games, stored as ASCII
#     BASIC. They must be no larger than 7920 bytes when
#     tokenized. The tokenized version will live inside a 0x?0 8KB
#     page at offset 0x10 and be mapped in the 0x8010-0x9EFF region.
#     The name will be shown in the menu upper case and with - turned into a space.
# - slot-?1-*-4k.asc
#     These are BASIC games, stored as ASCII
#     BASIC. They must be no larger than 4080 bytes when
#     tokenized. The tokenized version will live inside a 0x?1 8KB
#     page at offset 0x10 and be mapped in the 0x8010-0x8FFF region.
#     The name will be shown in the menu upper case and with - turned into a space.
# - slot-??-*-8k.rom, slot-??-*-16k.rom, slot-??-*-8k.ips, slot-??-*-16k.ips 
#     MSX ROM images. All of them must be runnable in the 0x8000-0xBFFF slot and not write to KonamiSCC or Konami4 mapper
#     register addresses. Also, they must have their entry point addresses written at offset 0x0002 right after the "AB"
#     bytes, as the menu will launch them by jumping to this address. BASIC ROM games won't work in these slots, sorry.
#
#     The -??- part in the filename is the hexadecimal lower case two-digit 8KB page number where the ROM will be placed
#     in the multicart. -?0- is reserved for the boot ROM and -?1- is reserved for the menu ROM and a BASIC game.
#
#     The names -tmp-boot- and -tmp-menu- are special and reserved, do not use them. Empty names are not allowed.
#
#     All 8KB slots in the overall 512KB ROM must be filled. Remember that 16KB games occupy two of them!
#     The name will be shown in the menu upper case and with - turned into a space.
#     If an .ips file is found with the same name it will be applied to create the version stored in the multicart.
# - menu.asc
#     This is the BASIC multicart menu, stored as ASCII. It must be no larger than 4096 bytes when tokenized.
#     A tokenization of this code will live inside each 0x?1 8KB page at offset 0x1000.
#     The program cannot use line number 0 or line numbers 65520 or above.
#     Lines 100-199 and lines 300-399 will be replaced by this script!
#     This file will be modified by this script!
# - banner.txt
#     This is the ASCII banner. Double quotes will be displayed as visible cursor block characters, character code 0xFF.
#     This will be converted into code and inserted into menu.asc.
#     This needs to fit in 13 or fewer lines of 29 or fewer characters.
# - boot.rom
#     This is the machine code boot ROM. It must be 8KB with the
#     region from 0x0010 through 0x1eff empty as it will be replaced
#     with a BASIC game in each ROM page. Bytes at offsets 0x0e and
#     0xef will be overwritten by the complement of the page number
#     and the page number, respectively.
#
#     It needs to map the menu into 0x8000 and launch it.
#
#     This one boots from 0x4000..0x7FFF.
#
#     A copy of this rom will live inside each 0x?0 8KB boot page with the final byte modified to be the page number.
#     A copy of the final byte (the page number) will live inside each 0x?D 8KB menu page at offset 0x100f.
#
# Build prerequisites:
#
# - awk (GNU version!)
# - bash
# - cut
# - diff
# - dd
# - fgrep
# - grep (GNU version!)
# - head
# - hexdump
# - ls
# - nl
# - od (GNU version!)
# - openmsx (including ROMs for Sony HB-501P and Sony HBD-F1)
# - python3
# - script (util-linux one seems to be working)
# - sed (GNU version!)
# - tr
# - wc
# - zip (Info-ZIP version!)
#
# ... probably others I forgot?
#
# The script is brittle. If it fails, try to fix it I guess?
#

bas_in_rom_prelude() {
    # This BASIC snippet is added to the BASIC menu program we prepare for
    # running from ROM.  It attempts to move BASIC's RAM usage to
    # 0xC000 and above to prevent writes to the ROM area which might
    # cause mapper state changes due to KonamiSCC/Konami4/Generic 8KB
    # mapper register switching address decoding in the 0x8000-0xBFFF
    # address range.
    #
    # It tries to move BOTTOM, TEMP, VARTAB, ARYTAB, and STREND.
    #
    # It needs to use \r\n line termination as it will be injected
    # into a TCL script with \n removed.  It needs to avoid unmatched
    # {} as it will be injected into TCL.
    #
    # Your BASIC menu should not define lines 0 or 65520-65529.
    printf '%s\r\n' \
           '0 IFI%=0THENI%=1:GOTO65521ELSEI%=0' \
           '65520 GOTO65529' \
           '65521 COLOR1,11,10:IF(PEEK(&H8000)<>65)OR(PEEK(&H8001)<>66)THEN65528' \
           '65522 IFPEEK(&HFC49)<192THENPOKE&HFC49,192:POKE&HFC48,0' \
           '65523 CLEAR300,PEEK(&HFC4A)+256*PEEK(&HFC4B):CLEAR' \
           '65524 IFPEEK(&HF6A8)<192THENPOKE&HF6A8,192:POKE&HF6A7,0' \
           '65525 IFPEEK(&HF6C3)<192THENPOKE&HF6C3,192:POKE&HF6C2,3' \
           '65526 IFPEEK(&HF6C5)<192THENPOKE&HF6C5,192:POKE&HF6C4,3' \
           '65527 IFPEEK(&HF6C7)<192THENPOKE&HF6C7,192:POKE&HF6C6,3' \
           '65528 I%=1:COLOR15,4,7:GOTO0' \
           '65529 ONERRORGOTO0'
}

scripted_openmsx() {
    : run openmsx without requiring a real TTY and attempt to prevent hangs :
    printf '[ running'
    printf ' %q' openmsx "$@"
    printf ' ]\n'
    {
        local n=20
        while test $n -gt 0 && sleep 1 && printf '\0'
        do
            if [ $n -lt 15 ]
            then
                echo -n $'\r'"[ waiting ${n}s ] " >&2
            fi
            n=$(( $n - 1 ))
        done
        if [ $n -lt 10 ]
        then
            echo $'\r'"[ no more waiting ] " >&2
        fi
    } |
        (
            exec > >(
                cat
            )
            script /dev/null \
                   --return \
                   --quiet \
                   --command 'pid=$$; ( n=22; ( while sleep 1 && [ $n -gt 0 ] && kill -0 $pid; do n=$(( $n - 1 )); done ) && kill -0 $pid && echo "[ sending signal to openmsx ]" >&2 && kill $pid ) & exec openmsx '"$(printf "%q'' " "$@")"'; exit $?'
            exit $?
        )
    local ret=$?
    if [ $ret != 0 ]
    then
        echo "[ openmsx exited with code $ret ]"
    fi
    return $ret
}

ascii_basic_crunch() {
    # attempt to slightly compact BASIC ASCII to avoid line buffer size limits
    #
    # the only implemented shortenings are:
    # 1. removal of space after initial line numbers
    # 2. replacement of some instances of PRINT with ?
    #
    # this tries to preserve "quoted things", REMarks,
    # 'remarks, and everything after DATA, CALL, and _
    #
    # input is stdin or supplied arguments, output is stdout
    cat "$@" |
        LC_ALL=C tr -d $'\r\x1a' | (
        while
            l=''
            # reads input lines including trailing spaces
            while read -r -s -N 1 c
            do
                if [ :"$c" = :$'\n' ]
                then
                    break
                fi
                l="$l$c"
            done
            test ${#l} -gt 0
        do
            n=""
            while [ :"${l#[0-9]}" != :"$l" ]
            do
                n="$n${l:0:1}"
                l="${l:1}"
            done
            if [ :"${l:0:1}" = :" " ]
            then
                l="${l:1}"
            fi
            r=""
            while [ ${#l} -gt 0 ]
            do
                x="${l:0:1}"
                l="${l:1}"
                if [ :"$x" = :'"' ]
                then
                    while [ :"${l:0:1}" != :'"' -a ${#l} -gt 0 ]
                    do
                        x="$x${l:0:1}"
                        l="${l:1}"
                    done
                    x="$x${l:0:1}"
                    l="${l:1}"
                elif [ :"$x" != :"${x//[A-Za-z]/}" ]
                then
                    while
                        y="${l:0:1}"
                        [ :"$y" != :"${y//[A-Za-z]/}" ]
                    do
                        x="$x$y"
                        l="${l:1}"
                    done
                fi
                if [ :"${x#PRINT}" != :"$x" ]
                then
                    x="?${x#PRINT}"
                fi
                if [ :"$x" = :'_' \
                      -o :"$x" = :"'" \
                      -o :"$x" != :"${x//[Rr][Ee][Mm]/}" \
                      -o :"$x" != :"${x//[Dd][Aa][Tt][Aa]/}" \
                      -o :"$x" != :"${x//[Cc][Aa][Ll][Ll]/}" \
                   ]
                then
                    x="$x$l"
                    l=''
                fi
                r="$r$x"
            done
            printf '%s\r\n' "$n$r"
        done
        printf '\x1a'
    )
}

rom_tokenize() {
    ascii_input="$1"
    tokenized_output="$2"
    tmp_ascii_output="$3"
    mkdir -p tmp-openmsx-diska &&
        ascii_basic_crunch < "$ascii_input" > tmp-openmsx-diska/input.asc &&
        ( rm -vf tmp-screen.txt || ( sleep 1 && rm -vf tmp-screen.txt ) ) &&
        scripted_openmsx \
            -machine Sony_HB-501P -ext Sony_HBD-F1 \
            -diska tmp-openmsx-diska \
            -command $'set fastforward on; set old_master_volume [set master_volume]; set master_volume 0' \
            -command $'after time 25 { type {\r keyoff:screen0,,0:color15,1,1:width40:cls\r }}' \
            -command $'after time 30 { type { load "input.asc" \r }}' \
            -command $'after time 55 { type { save "output.bas" \r }}' \
            -command $'after time 80 { type { save "output.asc", a \r }}' \
            -command $'after time 120 { set screen [get_screen]; set fp [open "tmp-screen.txt" w];puts $fp $screen; close $fp; set master_volume $old_master_volume; quit; }' &&
        (
            found="$(LC_ALL=C fgrep -a -e error -e Undefined -e Illegal -e Direct -e Ok tmp-screen.txt | LC_ALL=C tr -d '\r' | LC_ALL=C uniq -c | LC_ALL=C sed 's/  */ /g;s/  *$//;s/^  *//')"
            expected="4 Ok"
            if [ :"$found" != :"$expected" ] || ! [ -f tmp-openmsx-diska/output.bas ] || ! [ -f tmp-openmsx-diska/output.asc ]
            then
                echo 'OpenMSX screen:'
                cat tmp-screen.txt
                printf '%s: [%q]\n' found "$found" expected "$expected" >&2
                \ls -ld tmp-openmsx-diska/output.bas tmp-openmsx-diska/output.asc
                exit 1
            fi
        ) &&
        ( rm -vf tmp-screen.txt || ( sleep 1 && rm -vf tmp-screen.txt ) ) &&
        cp -v tmp-openmsx-diska/output.bas "$tokenized_output" &&
        cp -v tmp-openmsx-diska/output.asc "$tmp_ascii_output" &&
        ( rm -rvf tmp-openmsx-diska || ( sleep 1 && ( rm -rvf tmp-openmsx-diska || ( sleep 1 && rm -rvf tmp-openmsx-diska ) ) ) ) &&
        \ls -d "$tmp_ascii_output" &&
        echo ensuring "$ascii_input" re-saved with no differences &&
        diff -i -u <(
            (
                (
                    cat "$ascii_input" | LC_ALL=C tr -d $'\x1a'
                ) | LC_ALL=C sort -n
                printf '\x1a'
            ) | ascii_basic_crunch
        ) <( ascii_basic_crunch "$tmp_ascii_output" ) &&
        ( rm -v "$tmp_ascii_output" || ( sleep 1 && rm -v "$tmp_ascii_output" ) ) &&
        :
    return $?
}

rebuild() {
    : rebuild script for pirate multicart :

    echo rebuilding... &&
        echo checking script usability... &&
        script --version &&
        script --help |
            fgrep -e --command &&
        script --help |
            fgrep -e --return &&
        script --help |
            fgrep -e --quiet &&
        echo script: OK &&
        echo checking openmsx usability... &&
        scripted_openmsx --version &&
        scripted_openmsx --version |
            fgrep -e openMSX &&
        ! scripted_openmsx --this-flag-is-not-implemented &&
        echo openmsx: OK &&
        echo checking python3 usability... &&
        python3 --version |
            fgrep Python &&
        echo python3: OK &&
        echo checking awk usability... &&
        awk --version |
            fgrep GNU &&
        echo awk: OK &&
        echo checking sed usability... &&
        sed --version |
            fgrep GNU &&
        echo sed: OK &&
        echo checking grep usability... &&
        grep --version |
            fgrep GNU &&
        echo grep: OK &&
        echo checking zip usability... &&
        zip --version |
            fgrep Info-ZIP &&
        echo zip: OK &&
        echo checking hexdump usability... &&
        hexdump --version &&
        echo hexdump is OK |
            hexdump -C |
            fgrep '00000000  68 65 78 64 75 6d 70 20  69 73 20 4f 4b 0a        |hexdump is OK.|' &&
        echo hexdump: OK &&
        echo checking od usability... &&
        od --version |
            fgrep GNU &&
        echo od is OK |
            od -tx1 |
            fgrep '0000000 6f 64 20 69 73 20 4f 4b 0a' &&
        echo od: OK &&
        echo cleaning temporary and generated files... &&
        rm -vf \
           *~ \
           slot-?0-tmp-boot-8k.rom \
           slot-?1-tmp-menu-8k.rom \
           all-slots.rom \
           pirate-multicart.zip \
           pirate-multicart.rom \
           pirate-multicart-slot-?x.rom \
           tmp-menu.bas \
           tmp-menu.bld \
           tmp-menu.asc \
           tmp-all-slots.rom \
           tmp-screen.txt \
           tmp-slot-*.rom \
           tmp-slot-*.bas \
           tmp-slot-*.bld \
           tmp-slot-*.tmp &&
        ( rm -rvf tmp-openmsx-diska || ( sleep 1 && ( rm -rvf tmp-openmsx-diska || ( sleep 1 && rm -rvf tmp-openmsx-diska ) ) ) ) &&
        echo cleaning temporary and generated files: DONE &&
        echo checking openmsx Sony_HB-501P and Sony_HBD-F1 usability... &&
        ( rm -vf tmp-screen.txt || ( sleep 1 && rm -vf tmp-screen.txt ) ) &&
        scripted_openmsx \
            -machine Sony_HB-501P -ext Sony_HBD-F1 \
            -command $'set fastforward on; set old_master_volume [set master_volume]; set master_volume 0' \
            -command $'after time 15 { type {\r ?"OpenMSX: ";"OK!" \r } }' \
            -command $'after time 20 { set screen [get_screen]; set fp [open "tmp-screen.txt" w];puts $fp $screen; close $fp; set master_volume $old_master_volume; quit; }' &&
        (
            found="$(LC_ALL=C fgrep -a 'OpenMSX: OK!' tmp-screen.txt | LC_ALL=C tr -d '\r' | LC_ALL=C uniq -c | LC_ALL=C sed 's/  */ /g;s/  *$//;s/^  *//')"
            expected="1 OpenMSX: OK!"
            if [ :"$found" != :"$expected" ]
            then
                echo 'OpenMSX screen:'
                cat tmp-screen.txt
                printf '%s: [%q]\n' found "$found" expected "$expected" >&2
                exit 1
            fi
        ) &&
        ( rm -vf tmp-screen.txt || ( sleep 1 && rm -vf tmp-screen.txt ) ) &&
        echo checking openmsx Sony_HB-501P usability: OK &&
        echo checking for required file boot.rom... &&
        \ls -ld boot.rom &&
        test -f boot.rom &&
        echo should be $(( 0x2000 )) bytes &&
        test $( LC_ALL=C wc -c < boot.rom ) = $(( 0x2000 )) &&
        echo should have 00 byte at offset $(( 0x1fff )) &&
        test $( dd bs=1 skip=$(( 0x1fff )) count=1 < boot.rom | od -tx1 | awk '{print $2}' ) = 00 &&
        echo checking for required file boot.rom: OK &&
        echo checking for required file menu.asc... &&
        ls -d menu.asc &&
        test -f menu.asc &&
        echo checking for required file menu.asc: OK &&
        echo checking for required file banner.txt... &&
        ls -d banner.txt &&
        test -f banner.txt &&
        echo banner.txt must have 13 or fewer lines each with 29 or fewer characters &&
        tr -d $'\r\x1a' < banner.txt |
            LC_ALL=C sed -e 's/^\([^'$'\x01'']\|'$'\x01''.\)\{30,\}/&    <= LINE TOO LONG/' |
            nl -ba -v1 |
            LC_ALL=C sed 's/^[ \t]*14[ \t]*.*/&                                  <= TOO MANY LINES/' &&
        test $( tr -d $'\r\x1a' < banner.txt | wc -l ) -le 13 &&
        ! LC_ALL=C grep -e '^\([^'$'\x01'']\|'$'\x01''.\)\{30,\}' <(
            tr -d $'\r\x1a' < banner.txt
        ) > /dev/null &&
        echo checking for required file banner.txt: OK &&
        echo checking for required file slot-\?\?-\*.rom non-overlap... &&
        (
            printf '%s\n' slot-??-*.rom | sort | uniq -w 8 -d -D
            if [ :"$( printf '%s\n' slot-??-*.rom | sort | uniq -w 8 -d -D )" != :"" ]
            then
                echo overlapping slot ROM entries >&2
                exit 1
            fi
        ) &&
        echo checking for required files slot-\?0-\*-7k.asc... &&
        set slot-{0,1,2,3}0-*-7k.asc &&
        ls -d "$@" &&
        test -f "$1" &&
        test -f "$2" &&
        test -f "$3" &&
        test -f "$4" &&
        echo checking for required files "$*": OK &&
        echo checking for required files slot-\?1-\*-4k.asc... &&
        set slot-{0,1,2,3}1-*-4k.asc &&
        ls -d "$@" &&
        test -f "$1" &&
        test -f "$2" &&
        test -f "$3" &&
        test -f "$4" &&
        echo checking for required files "$*": OK &&
        echo updating menu.asc... &&
        (
            : ' lines 1xx and 3xx will be tossed and replaced ' :
            : ' "double quotes" in banner.txt will be replaced with character 0xFF, the visible cursor block ' :
            bas_in_rom_prelude | tr -d '\r'$'\x1a'
            LC_ALL=C sed -ne 's/^  *//;/^[^13]\|^[13][^0-9]\|^[13][0-9][^0-9]\|^[13][0-9][0-9][0-9]/ p' menu.asc |
                tr -d '\r'$'\x1a'
            (
                echo -n "DATA$(
                    printf '%s\n' slot-*.asc slot-*.rom |
                        sort |
                        grep -v -e '^slot-..-tmp-menu-8k\.rom$' -e '^slot-..-tmp-boot-8k\.rom$' |
                        sed -e 's/"/"+CHR$(34)+"/g' \
                            -e 's/^slot-\([0-9a-fA-F][0-9a-fA-F]\)-\(.*\)-\(..\|.\)k\.asc$/\&H8\1,"\2"/' \
                            -e 's/^slot-0*\([0-9a-fA-F]\|[1-9a-fA-F][0-9a-fA-F]\)-\(.*\)-\(..\|.\)k\.rom$/\&H\1,"\2"/' \
                            -e 's/-/ /g' |
                        tr 'a-z' 'A-Z'
                        echo '-1,""'
                    )" |
                    tr '\n' '/' |
                    sed -e 's_.\{,240\}/_&/DATA_g;s_\([^/]\)/\([^/]\)_\1,\2_g;s_//_/_g' |
                    tr '/' '\n'
                echo
            ) |
                LC_ALL=C grep . |
                nl -ba -v100 |
                tr '\t' ' ' |
                sed 's/^ *//'
            echo '198 RESTORE100:DIMII%(256),NN$(256):E%=0'
            echo '199 READII%(E%),NN$(E%):IFNN$(E%)<>""THENE%=E%+1:GOTO199'
            tr -d '\r'$'\x1a' < banner.txt |
                LC_ALL=C tr '"' $'\xFF' |
                LC_ALL=C sed 's/^\([^'$'\x01'']\|'$'\x01''.\)\{29,29\}$/&";/' |
                LC_ALL=C nl -ba -v300 |
                LC_ALL=C sed 's/^ *\([0-9][0-9]*\)'$'\t''/\1 PRINT"/'
        ) |
            LC_ALL=C sort -n |
            LC_ALL=C uniq |
            LC_ALL=C sed $'s/$/\r/' > tmp-menu.asc &&
        printf '\x1a' >> tmp-menu.asc &&
        (
            diff -i -u <( ascii_basic_crunch menu.asc ) <( ascii_basic_crunch tmp-menu.asc ) ||
                mv -v tmp-menu.asc menu.asc
        ) &&
        rm -vf tmp-menu.asc &&
        echo updating menu.asc: OK &&
        echo generating tokenized tmp-menu.bas... &&
        rom_tokenize menu.asc tmp-menu.bas tmp-menu.asc &&
        \ls -ld tmp-menu.bas &&
        echo should be $(( 0x1000 )) bytes or smaller &&
        test $( LC_ALL=C wc -c < tmp-menu.bas ) -le $(( 0x1000 )) &&
        dd bs=1 count=1 < tmp-menu.bas | od -tx1 | awk '{print $2}' &&
        echo should have FF byte at offset 0 &&
        test $( dd bs=1 count=1 < tmp-menu.bas | od -tx1 | awk '{print $2}' ) = ff &&
        echo generating tokenized tmp-menu.bas: OK &&
        echo testing basld de-tokenization for tmp-menu.bas and generating tmp-menu.bld... &&
        python3 basld.py 0x9000 tmp-menu.bas tmp-menu.bld tmp-menu.asc &&
        echo ensuring tmp-menu.bas de-tokenized with no differences &&
        \ls -d tmp-menu.asc &&
        diff -i -u <(
            (
                (
                    cat menu.asc | LC_ALL=C tr -d $'\x1a'
                ) | LC_ALL=C sort -n
                printf '\x1a'
            ) | ascii_basic_crunch
        ) <( ascii_basic_crunch tmp-menu.asc ) &&
        ( rm -v tmp-menu.asc || ( sleep 1 && rm -v tmp-menu.asc ) ) &&
        echo ensuring tmp-menu.bld is the same length as tmp-menu.bas &&
        \ls -ld tmp-menu.bas tmp-menu.bld &&
        test $( LC_ALL=C wc -c < tmp-menu.bas ) = $( LC_ALL=C wc -c < tmp-menu.bld ) &&
        dd bs=1 count=1 < tmp-menu.bld | od -tx1 | awk '{print $2}' &&
        echo should have 00 byte at offset 0 &&
        test $( dd bs=1 count=1 < tmp-menu.bld | od -tx1 | awk '{print $2}' ) = 00 &&
        echo testing basld de-tokenization for tmp-menu.bas and generating tmp-menu.bld: OK &&
        (
            for p in 0 1 2 3
            do
                : &&
                    : ' larger game that coexists with the boot code ' : &&
                    : &&
                    echo generating tokenized tmp-slot-${p}0.bas... &&
                    rom_tokenize slot-${p}0-*-7k.asc tmp-slot-${p}0.bas tmp-slot-${p}0.asc &&
                    echo generating tokenized tmp-slot-${p}0.bas: OK &&
                    echo checking tokenized tmp-slot-${p}0.bas... &&
                    \ls -ld tmp-slot-${p}0.bas &&
                    echo should be $(( 0x2000 - 0x100 - 0x10 )) bytes or smaller &&
                    test $( LC_ALL=C wc -c < tmp-slot-${p}0.bas ) -le $(( 0x2000 - 0x100 - 0x10 )) &&
                    dd bs=1 count=1 < tmp-slot-${p}0.bas | od -tx1 | awk '{print $2}' &&
                    echo should have FF byte at offset 0 &&
                    test $( dd bs=1 count=1 < tmp-slot-${p}0.bas | od -tx1 | awk '{print $2}' ) = ff &&
                    echo checking tokenized tmp-slot-${p}0.bas: OK &&
                    echo testing basld de-tokenization for tmp-slot-${p}0.bas and generating tmp-slot-${p}0.bld... &&
                    python3 basld.py 0x8010 tmp-slot-${p}0.bas tmp-slot-${p}0.bld tmp-slot-${p}0.tmp &&
                    echo ensuring tmp-slot-${p}0.bas de-tokenized with no differences &&
                    \ls -d tmp-slot-${p}0.tmp &&
                    diff -i -u <(
                        (
                            (
                                cat slot-${p}0-*-7k.asc | LC_ALL=C tr -d $'\x1a'
                            ) | LC_ALL=C sort -n
                            printf '\x1a'
                        ) | ascii_basic_crunch
                    ) <( ascii_basic_crunch tmp-slot-${p}0.tmp ) &&
                    ( rm -v tmp-slot-${p}0.tmp || ( sleep 1 && rm -v tmp-slot-${p}0.tmp ) ) &&
                    echo ensuring tmp-slot-${p}0.bld is the same length as tmp-slot-${p}0.bas &&
                    \ls -ld tmp-slot-${p}0.bas tmp-slot-${p}0.bld &&
                    test $( LC_ALL=C wc -c < tmp-slot-${p}0.bas ) = $( LC_ALL=C wc -c < tmp-slot-${p}0.bld ) &&
                    dd bs=1 count=1 < tmp-slot-${p}0.bld | od -tx1 | awk '{print $2}' &&
                    echo should have 00 byte at offset 0 &&
                    test $( dd bs=1 count=1 < tmp-slot-${p}0.bld | od -tx1 | awk '{print $2}' ) = 00 &&
                    echo testing basld de-tokenization for tmp-slot-${p}0.bas and generating tmp-slot-${p}0.bld: OK &&
                    : &&
                    : ' smaller game that coexists with the menu ' : &&
                    : &&
                    echo generating tokenized tmp-slot-${p}1.bas... &&
                    rom_tokenize slot-${p}1-*-4k.asc tmp-slot-${p}1.bas tmp-slot-${p}1.asc &&
                    echo generating tokenized tmp-slot-${p}1.bas: OK &&
                    echo checking tokenized tmp-slot-${p}1.bas... &&
                    \ls -ld tmp-slot-${p}1.bas &&
                    echo should be $(( 0x1000 )) bytes or smaller &&
                    test $( LC_ALL=C wc -c < tmp-slot-${p}1.bas ) -le $(( 0x1000 )) &&
                    dd bs=1 count=1 < tmp-slot-${p}1.bas | od -tx1 | awk '{print $2}' &&
                    echo should have FF byte at offset 0 &&
                    test $( dd bs=1 count=1 < tmp-slot-${p}1.bas | od -tx1 | awk '{print $2}' ) = ff &&
                    echo checking tokenized tmp-slot-${p}1.bas: OK &&
                    echo testing basld de-tokenization for tmp-slot-${p}1.bas and generating tmp-slot-${p}1.bld... &&
                    python3 basld.py 0x8010 tmp-slot-${p}1.bas tmp-slot-${p}1.bld tmp-slot-${p}1.tmp &&
                    echo ensuring tmp-slot-${p}1.bas de-tokenized with no differences &&
                    \ls -d tmp-slot-${p}1.tmp &&
                    diff -i -u <(
                        (
                            (
                                cat slot-${p}1-*-4k.asc | LC_ALL=C tr -d $'\x1a'
                            ) | LC_ALL=C sort -n
                            printf '\x1a'
                        ) | ascii_basic_crunch
                    ) <( ascii_basic_crunch tmp-slot-${p}1.tmp ) &&
                    ( rm -v tmp-slot-${p}1.tmp || ( sleep 1 && rm -v tmp-slot-${p}1.tmp ) ) &&
                    echo ensuring tmp-slot-${p}1.bld is the same length as tmp-slot-${p}1.bas &&
                    \ls -ld tmp-slot-${p}1.bas tmp-slot-${p}1.bld &&
                    test $( LC_ALL=C wc -c < tmp-slot-${p}1.bas ) = $( LC_ALL=C wc -c < tmp-slot-${p}1.bld ) &&
                    dd bs=1 count=1 < tmp-slot-${p}1.bld | od -tx1 | awk '{print $2}' &&
                    echo should have 00 byte at offset 0 &&
                    test $( dd bs=1 count=1 < tmp-slot-${p}1.bld | od -tx1 | awk '{print $2}' ) = 00 &&
                    echo testing basld de-tokenization for tmp-slot-${p}1.bas and generating tmp-slot-${p}1.bld: OK &&
                    :
                ret=$?
                if [ $ret != 0 ]
                then
                    exit $ret
                fi
            done
        ) &&
        echo generating slot-\?0-tmp-boot-8k.rom... &&
        (
            for p in 0 1 2 3
            do
                echo "$p"
                (
                    dd bs=1 count=$(( 0x0e )) < boot.rom
                    LC_ALL=C printf "$(printf '\\x%02x' $(( 0x${p}0 ^ 0xff )) $(( 0x${p}0 )) )"
                    dd bs=1 < tmp-slot-${p}0.bld
                    dd bs=1 count=$(( 0x1f00 - ( 0x10 + $( LC_ALL=C wc -c < tmp-slot-${p}0.bld ) ) )) if=/dev/zero
                    dd bs=1 skip=$(( 0x1f00 )) < boot.rom
                ) > slot-${p}0-tmp-boot-8k.rom
            done
        ) &&
        echo generating slot-\?0-tmp-boot-8k.rom: OK &&
        echo generating slot-\?1-tmp-menu-8k.rom... &&
        (
            for p in 0 1 2 3
            do
                (
                    printf 'AB\x00\x5f\0\0\0\0\x00\x90\0\0\0\0'"$(printf '\\x%02x' $(( 0x${p}1 ^ 0xff )) $(( 0x${p}1 )) )"
                    dd bs=1 < tmp-slot-${p}1.bld
                    dd bs=1 count=$(( 0x1000 - ( 0x10 + $( LC_ALL=C wc -c < tmp-slot-${p}1.bld ) ) )) if=/dev/zero
                    dd bs=1 < tmp-menu.bld
                    dd bs=1 count=$(( 0x1000 - $( LC_ALL=C wc -c < tmp-menu.bld ) )) if=/dev/zero
                ) > slot-${p}1-tmp-menu-8k.rom
            done
        ) &&
        rm -vf tmp-slot-*.bas &&
        echo generating slot-\?1-tmp-menu-8k.rom: OK &&
        rm -vf tmp-menu.bas tmp-menu.bld &&
        echo generating all-slots.rom... &&
        rm -vf tmp-all-slots.rom &&
        : > tmp-all-slots.rom &&
        (
            i=$(( 0x00 ))
            for slot in slot-*.rom
            do
                if [ :"$slot" = :"${slot/slot-$(printf %02x $i)-/}" ]
                then
                    echo "$slot found, slot-$(printf %02x $i)-* expected" >&2
                    exit 1
                fi
                tmpslot="tmp-slot-$(printf %02x $i).rom"
                if ! rm -vf "$tmpslot"
                then
                    exit $?
                fi
                if [ -f "${slot/.rom/}.ips" ]
                then
                    echo applying IPS patch
                    if ! python3 apply_ips.py "${slot/.rom/}.ips" "$slot" "$tmpslot"
                    then
                        exit $?
                    fi
                else
                    if ! cp -v "$slot" "$tmpslot"
                    then
                        exit $?
                    fi
                fi
                expected_slot_suffix="-$(printf %dk $(( $( LC_ALL=C wc -c < "$tmpslot" ) / 1024 )) ).rom"
                if [ :"$slot" = :"${slot/"$expected_slot_suffix"/}" -o $(( $( LC_ALL=C wc -c < "$tmpslot" ) % 0x2000 )) != 0 ]
                then
                    \ls -dl "$tmpslot"
                    echo "$slot found, *$expected_slot_suffix expected with size a multiple of 8KB" >&2
                    exit 1
                fi
                hexdump -C "$tmpslot" |
                    head -1
                if [ :"$slot" != :"${slot/slot-?0-tmp-boot-8k.rom/}" ] &&
                       ! hexdump -C "$tmpslot" |
                           head -1 |
                           grep -e '^00000000  41 42 .. [4567]' > /dev/null
                then
                    echo "$slot boot ROM entry point is not in the 0x4000-0x7FFF range" >&2
                    exit 1
                elif [ :"$slot" != :"${slot/slot-?1-tmp-menu-8k.rom/}" ] &&
                         ! hexdump -C "$tmpslot" |
                             head -1 |
                             grep -e '^00000000  41 42 .. .. .. .. .. ..  .. [89abAB]' > /dev/null
                then
                    echo "$slot menu ROM BASIC entry point is not in the 0x8000-0xBFFF range" >&2
                    exit 1
                elif [ :"$slot" = :"${slot/slot-?0-tmp-boot-8k.rom/}" -a :"$slot" = :"${slot/slot-?1-tmp-menu-8k.rom/}" ] &&
                         ! hexdump -C "$tmpslot" |
                             head -1 |
                             grep -e '^00000000  41 42 .. [89abAB]' > /dev/null
                then
                    echo "$slot regular ROM entry point is not in the 0x8000-0xBFFF range" >&2
                    exit 1
                fi
                i=$(( $i + ( $( LC_ALL=C wc -c < "$tmpslot" ) / 0x2000 ) ))
                if ! cat "$tmpslot" >> tmp-all-slots.rom &&
                        rm -v "$tmpslot"
                then
                    exit $?
                fi
            done
            if [ $i != $(( 0x40 )) ]
            then
                echo expected to fill $(( 0x40 )) 8KB slots but actually filled $i >&2
                exit 1
            fi
        ) &&
        (
            if [ $(( (512 * 1024) - $(cat tmp-all-slots.rom | LC_ALL=C wc -c) )) != 0 ]; then
                echo "slot contents do not sum to 512KB" >&2
                exit 1
            fi
        ) &&
        cp -v tmp-all-slots.rom all-slots.rom &&
        rm -vf tmp-all-slots.rom &&
        rm -vf slot-?0-tmp-boot-8k.rom slot-?1-tmp-menu-8k.rom &&
        echo generating all-slots.rom: OK &&
        echo generating pirate-multicart-slot-\?x.rom... &&
        (
            for p in 0 1 2 3
            do
                dd bs=$((128*1024)) count=1 skip=$p < all-slots.rom > pirate-multicart-slot-${p}x.rom
            done
        ) &&
        echo generating pirate-multicart-slot-\?x.rom: OK &&
        echo generating pirate-multicart.rom... &&
        cp -v all-slots.rom pirate-multicart.rom &&
        echo generating pirate-multicart.rom: OK &&
        rm -vf tmp-slot-*.rom tmp-slot-*.bld &&
        echo testing pirate-multicart.rom... &&
        echo ... with mapper Konami4 &&
        ( rm -vf tmp-screen.txt || ( sleep 1 && rm -vf tmp-screen.txt ) ) &&
        scripted_openmsx \
            -machine Sony_HB-501P \
            pirate-multicart.rom \
            -romtype konami4 \
            -command $'set fastforward on; set old_master_volume [set master_volume]; set master_volume 0' \
            -command $'after time 25 { set screen [get_screen]; set fp [open "tmp-screen.txt" w];puts $fp $screen; close $fp; set master_volume $old_master_volume; quit; }' &&
        (
            found="$(LC_ALL=C fgrep -a -e error -e Undefined -e Illegal -e Direct -e Ok -e DIPS tmp-screen.txt | LC_ALL=C tr -d '\r' | LC_ALL=C sed 's/  */ /g;s/  *$//;s/^  *//')"
            expected="DIPS 0000=0000"
            if [ :"$found" != :"$expected" ]
            then
                echo 'OpenMSX screen:'
                cat tmp-screen.txt
                printf '%s: [%q]\n' found "$found" expected "$expected" >&2
                exit 1
            fi
        ) &&
        ( rm -vf tmp-screen.txt || ( sleep 1 && rm -vf tmp-screen.txt ) ) &&
        echo ... with mapper KonamiSCC &&
        scripted_openmsx \
            -machine Sony_HB-501P \
            pirate-multicart.rom \
            -romtype konamiscc \
            -command $'set fastforward on; set old_master_volume [set master_volume]; set master_volume 0' \
            -command $'after time 25 { set screen [get_screen]; set fp [open "tmp-screen.txt" w];puts $fp $screen; close $fp; set master_volume $old_master_volume; quit; }' &&
        (
            found="$(LC_ALL=C fgrep -a -e error -e Undefined -e Illegal -e Direct -e Ok -e DIPS tmp-screen.txt | LC_ALL=C tr -d '\r' | LC_ALL=C sed 's/  */ /g;s/  *$//;s/^  *//')"
            expected="DIPS 0000=0000"
            if [ :"$found" != :"$expected" ]
            then
                echo 'OpenMSX screen:'
                cat tmp-screen.txt
                printf '%s: [%q]\n' found "$found" expected "$expected" >&2
                exit 1
            fi
        ) &&
        ( rm -vf tmp-screen.txt || ( sleep 1 && rm -vf tmp-screen.txt ) ) &&
        echo testing pirate-multicart.rom: OK &&
        (
            for p in 0 1 2 3
            do
                echo testing pirate-multicart-slot-${p}x.rom... &&
                    ( rm -vf tmp-screen.txt || ( sleep 1 && rm -vf tmp-screen.txt ) ) &&
                    scripted_openmsx \
                        -machine Sony_HB-501P \
                        pirate-multicart-slot-${p}x.rom \
                        -romtype 8kb \
                        -command $'set fastforward on; set old_master_volume [set master_volume]; set master_volume 0' \
                        -command $'after time 25 { set screen [get_screen]; set fp [open "tmp-screen.txt" w];puts $fp $screen; close $fp; set master_volume $old_master_volume; quit; }' &&
                    (
                        found="$(LC_ALL=C fgrep -a -e error -e Undefined -e Illegal -e Direct -e Ok -e DIPS tmp-screen.txt | LC_ALL=C tr -d '\r' | LC_ALL=C sed 's/  */ /g;s/  *$//;s/^  *//')"
                        pdips="$(python3 -c 'import sys; _, p = sys.argv; print(bin(0x100 | int(p) )[-4:])' $p)"
                        expected="DIPS $pdips=$pdips"
                        if [ :"$found" != :"$expected" ]
                        then
                            echo 'OpenMSX screen:'
                            cat tmp-screen.txt
                            printf '%s: [%q]\n' found "$found" expected "$expected" >&2
                            exit 1
                        fi
                    ) &&
                    ( rm -vf tmp-screen.txt || ( sleep 1 && rm -vf tmp-screen.txt ) ) &&
                    echo testing pirate-multicart-slot-${p}x.rom: OK
                ret=$?
                if [ $ret != 0 ]
                then
                    exit $ret
                fi
            done
        ) &&
        echo generating pirate-multicart.zip... &&
        zip -j9r pirate-multicart.zip . &&
        echo generating pirate-multicart.zip: OK &&
        echo rebuilding: OK
    exit $?
}

rebuild "$@"; exit $?