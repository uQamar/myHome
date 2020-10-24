#!/usr/bin/env bash

function run {
    if ! pgrep $1 ; then
        $@&
    fi
}


#rxvt -e "nmcli dev wifi connect 'PTCL-Tayyab089' password '8949bff0'"
