#!/bin/bash

rcntln () {
    local FOLDER=$1 || $PWD
    local NLINES=0
    for i in $FOLDER/*; do
        if [[ -d "$i" ]]; then
            let NLINES+=$(rcntln "$i" | awk '{print $1}')
        else
            let NLINES+=$(wc -l "$i" | awk '{print $1}')
        fi
    done
    echo "$NLINES TOTAL"
}

rcntln "$@"
