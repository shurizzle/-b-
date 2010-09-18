#!/bin/bash

: ${1?"USAGE: filsh <videolink>"}
curl -s -F "links=${1}" -F 'format=none' -F 'volume=0' -F 'audiobit=128' -F 'videobit=192' -F 'dimensions=0' -F 'timespan-from-start=0' -F 'timespan-to-end=0' -F 'button=Weiter Â»' -F 'rules_accepted=on' http://www.filsh.net/process/ | grep -Po '<a href=".+?">Download( \(LQ\))?</a>' | sed -r 's/<a href="|">Download.+?<\/a>//g'
