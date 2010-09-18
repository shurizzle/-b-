#!/bin/bash

if [[ ! -e ~/.imgshack && -e ~/.imgshackrc ]]; then
    . ~/.imgshackrc
    curl -s -c ~/.imgshack -b ~/.imgshack -H Expect: -F "username=${USERNAME}" -F "password=${PASSWORD}" -F 'stay_logged_in=true' -F 'format=json' www.imageshack.us/auth.php
fi

if [[ -e ~/.imgshack ]]; then
    link=$(curl -s -D - -c ~/.imgshack -b ~/.imgshack -F "fileupload=@${1}" -F 'refer=http://my.imageshack.us/v_images.php' -F 'MAX_FILE_SIZE=13145728' -F 'uploadtype=on' -F 'optimage=resample' -F 'optsize=resample' -F 'rembar=0' www.imageshack.us/index.php | grep -i 'location: ' | cut -c 11- | sed -r 's/content_round\.php\?page=done&l=//')
else
    link=$(curl -s -H Expect: -F "fileupload=@${1}" -F xml=yes http://www.imageshack.us/index.php | grep -E '<image_link>(.+?)</image_link>' | grep -o 'http://[^<]*')
fi

if [[ -z "${link}" ]]; then
    link="Failed to upload image"
fi

echo "${link}"
