#!/bin/bash

DB="${HOME}/.stpass"

new_id ()
{
    [ -e "${DB}" ] || touch "${DB}"
    local ID="$(echo "$(tail -n1 "${DB}" | awk -F: '{print $1}') + 1" | bc 2>/dev/null)"
    echo ${ID:-1}
}

stpass_add ()
{
    : ${3?"USAGE: $0 add <site> <username> <password>"}
    echo "$(new_id):${1}:${2}:${3}" >> "${DB}"
}

stpass_show ()
{
    : ${1?"USAGE: $0 show <id>"}
    grep "^${1}" "${DB}" | sed 's/:/\t/g'
}

stpass_list ()
{
    sed 's/:/\t/g' "${DB}"
}

stpass_del ()
{
    : ${1?"USAGE: $0 del <id>"}
    tmp="/tmp/$(mktemp stXXX)"
    grep -v "^${1}" "${DB}" > "${tmp}"
    rm "${DB}"
    mv "${tmp}" "${DB}"
}

stpass_help ()
{
    echo "${0} USAGE:"
    echo "    ${0} <add|show|list|del|help>"
}

FUNC="${1}"
shift

eval "stpass_${FUNC} \"\$@\"" 2>/dev/null || stpass_help
