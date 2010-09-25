#!/bin/bash

die () {
    echo -e "\e[31;1mERROR:\e[0m ${1}" >&2
    exit 1
}

alert () {
    echo -e "\e[34;1m->\e[0m ${1}"
}

[ ! -z "${LFM_USER}" -a ! -z "${LFM_PASS}" ] || . "${HOME}/.bashcrobblerrc"
[ ! -z "${LFM_USER}" -a ! -z "${LFM_PASS}" ] || die "LFM_USER and LFM_PASS not setted"

TIMESTAMP="$(date --utc +%s)"

CLIENT_NAME="tst"
CLIENT_VERSION="1.0"

url_encode () {
    echo -n "${1}" | sed -e's/./&\n/g' -e's/ /%20/g' | grep -v '^$' | while read CHAR; do test "${CHAR}" = "%20" && echo "${CHAR}" ||\
        echo "${CHAR}" | grep -E '[-[:alnum:]!*.'"'"'()]|\[|\]' || echo -n "${CHAR}" | od -t x1 | tr ' ' '\n' | grep '^[[:alnum:]]\{2\}$' |\
        tr '[a-z]' '[A-Z]' | sed -e's/^/%/g'; done | sed -e's/%20/+/g' | tr -d '\n'
}

md5 () {
    echo -n "$(echo -n "${1}" | md5sum -t | awk '{print $1}')"
}

get_auth () {
    md5 "$(md5 "${LFM_PASS}")${TIMESTAMP}"
}

authentication () {
    alert "Authenticating..."
    local RES="$(wget -O - "http://post.audioscrobbler.com/?hs=true&p=1.2.1&c=$(url_encode "${CLIENT_NAME}")&v=$(url_encode "${CLIENT_VERSION}")&u=$(url_encode "${LFM_USER}")&t=${TIMESTAMP}&a=$(get_auth)" 2>/dev/null)"
    [ "$(echo "${RES}" | head -n1)" == "OK" ] || die "${RES}"
    SESSID="$(echo "${RES}" | head -n2 | tail -n1)"
    NOW_PLAYING_URL="$(echo "${RES}" | head -n3 | tail -n1)"
    SUBMISSION_URL="$(echo "${RES}" | tail -n1)"
    alert "Authetication succeded."
}

get_moc_infos () {
    alert "Taking music infos..."
    local INFOS="$(mocp -i | grep -E '^(Artist|SongTitle|Album|TotalSec):' | sed -r 's/^.+?:\s+//g')"
    ARTIST="$(echo "${INFOS}" | head -n1)"
    TRACK="$(echo "${INFOS}" | head -n2 | tail -n1)"
    ALBUM="$(echo "${INFOS}" | tail -n2 | head -n1)"
    DURATION="$(echo "${INFOS}" | tail -n1)"
    echo -ne "ARTIST=\"${ARTIST}\"\nTRACK=\"${TRACK}\"\nALBUM=\"${ALBUM}\"\nDURATION=\"${DURATION}\"" > "${HOME}/.moc/last_song"
    alert "Infos taken."
}

now_playing_notification () {
    get_moc_infos
    alert "Now-Playing notifying..."
    local RES="$(wget -O - --post-data="s=${SESSID}&a=$(url_encode "${ARTIST}")&t=$(url_encode "${TRACK}")&b=$(url_encode "${ALBUM}")&l=${DURATION}" "${NOW_PLAYING_URL}" 2>/dev/null)"
    [ "${RES}" == "OK" ] || die "${RES}"
    alert "Now-Playing notified."
}

submission () {
    alert "Submitting..."
    local RES="$(wget -O - --post-data="s=${SESSID}&a%5B0%5D=$(url_encode "${ARTIST}")&t%5B0%5D=$(url_encode "${TRACK}")&i%5B0%5D=${TIMESTAMP}&o%5B0%5D=P&r%5B0%5D=L&l%5B0%5D=${DURATION}&b%5B0%5D=$(url_encode "${ALBUM}")&n%5B0%5D=&m%5B0%5D=" "${SUBMISSION_URL}" 2>/dev/null)"
    [ "${RES}" == "OK" ] || die "${RES}"
    alert "Submitted."
}

authentication
now_playing_notification
