#!/bin/bash

DIR="${HOME}/screenshots"
IMG="${DIR}/`date +%Y%m%d%H%M%S`.png"
LOG="${DIR}/logs"
DATE=$(date +'[%d/%m/%Y %H:%M:%S]')

if [[ -z "$(which scrot)" ]]; then
    echo "Install $i first"
    exit
fi

if [[ ! -e "${DIR}" ]]; then
    mkdir -p "${DIR}"
fi

if [[ "${1}" = "-s" ]]; then
    scrot -d 3 "${IMG}"
else
    scrot -c -d 3 "${IMG}"
fi

LNK=$(imageshack "${IMG}")
echo "${DATE} ${LNK}" >> "${LOG}"
echo "${LNK}"
