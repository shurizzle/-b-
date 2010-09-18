#!/bin/bash

[ $1 == '-h' -o $1 == '--help' ] && echo "USAGE: ${0} [-h|-q] [regex]" && exit 0
[ $1 == '-q' -o $1 == '--quiet' ] && shift && QUIET=1

REGEX=${1:-".*"}

eval "X=($(ps ax | sed -r 's/^\s*([0-9]+)\s+\S+\s+\S+\s+\S+\s+(.+)$/\1|\2/' | grep -P '[0-9]+\|'"${REGEX}" | sed -r 's/([0-9]+)\|(.+)$/"\1" "\2"/' | tr '\n' ' '))"

for ((i=0; $i < ${#X[*]}; i+=2)); do
    [ $$ == ${X[$i]} ] && continue
    echo -n "Kill '${X[((i + 1))]}\`? (Y/n) "
    [ $QUIET ] && C="Yes" || read C
    case $C in
        [Nn]|[Nn][Oo])
        ;;
        *)
            echo "[+] Killing process..."
            kill -9 ${X[$i]} &>/dev/null && echo "[+] Killed." || echo "[+] Couldn't kill process."
        ;;
    esac
done
