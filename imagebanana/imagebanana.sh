#!/bin/bash

: ${1?"USAGE: ${0} <image>"}

curl -s -L -H Expect: -F "img=@${1}" -F 'send=Hochladen!' imagebanana.com | grep '\[IMG\]' | sed -r 's/.*\[IMG\]|\[\/IMG\].*//g' | tail -n 1
