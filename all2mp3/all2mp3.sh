#!/bin/bash

: ${1?"USAGE ${0} <file.ext>"}
$FILE=$(mktemp a2m-XXX.wav)
mplayer "${1}" -ao pcm:file="${FILE}" -vo null
lame "${FILE}" "$(echo "${1}" | sed -r 's/\.[^.]+?$//').mp3"
rm "${FILE}"
