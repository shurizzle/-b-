#!/bin/bash

megaupload ()
{
    case $1 in
    	"-l")
    		: ${3?"Login need 2 parameters"}
    		wget --load-cookies ~/.sdler --save-cookies ~/.sdler --post-data "login=1&redir=1&username=$2&password=$3" --save-headers http://www.megaupload.com/?c=login -O ~/.megaup 2> /dev/null
    		page=`cat ~/.megaup`
    		rm ~/.megaup
    		message="<b>Welcome</b> <font style=\"color:#F3781A; font-weight:bold;\">$2"
    		if [[ "$page" =~ "$message" ]]; then
    			echo "Login effettuato"
    		else
    			echo "Login fallito"
    		fi
    	;;
    	"-d")
    		: ${2?"Download need 1 parameter"}
    		numl=$#
    		if [[ -e ~/.sdler ]]; then
    			for i in `seq 2 $numl`; do
    				wget -c --load-cookies ~/.sdler $2
    				shift
    			done
    		else
    			echo "Loggati prima"
    		fi
    	;;
      	"-f")
	    	: ${3?"Fetch need 2 parameters"}
	    	numl=$#
	    	if [[ -f ~/.sdler ]]; then
    			for i in `seq 3 $numl`; do
    				wget --load-cookies ~/.sdler --post-data "fetchurl=$3&description=$2" http://www.megaupload.com/?c=multifetch -O ~/.mures 2> /dev/null
    				rm ~/.mures
    				echo "$3 fetched"
    				shift
    			done
    		else
    			echo "Loggati prima"
    		fi
    	;;
    	"-u")
    		: ${3?"Upload need 2 parameters"}
    		uplink=`curl -s -b ~/.sdler -c ~/.sdler http://www.megaupload.com/ | grep '<FORM style="display: inline;" METHOD="POST"  ENCTYPE="multipart/form-data" action="' | awk -F '"' {'print $8'}`
    		curl -b ~/.sdler -c ~/.sdler -F uploadcnt=0 -F "multimessage_0=$2" -F "multifile_0=@$3" $uplink | grep multiresult | awk -F "'" {'print $6'}
    	;;
    	"-g")
    		: ${2?"Generate need 1 parameter"}
    		link=`curl -s -b ~/.sdler -c ~/.sdler -D - $2 | grep -i Location | cut -c 10-`
    		for i in $link
    		do
    			link=$i
    		done
    		echo $link
    	;;
    	*)
    		echo "-l USERNAME PASSWORD             - login to megaupload"
    		echo "-d link1 [link2] ...             - download files"
    		echo "-f description link1 [link2] ... - fetch files"
    		echo "-u description file.ext          - upload a file"
    		echo "-g link                          - generate premium link"
    	;;
    esac
}

rapidshare ()
{
    case $1 in
        "-l")
            : ${3?"Login need 2 parameters"}
            wget --load-cookies ~/.sdler --save-cookies ~/.sdler --post-data "uselandingpage=1&login=$2&password=$3" \
                --save-headers https://ssl.rapidshare.com/cgi-bin/premiumzone.cgi -O ~/.rapid 2> /dev/null
            rm ~/.rapid
            echo "Logged in"
        ;;
        "-d")
            : ${2?"Download need 1 parameter"}
            if [[ -e ~/.sdler ]]; then
                wget -c --load-cookies ~/.sdler $2
            else
                echo "Loggati prima"
            fi
        ;;
        *)
            echo "-l USERNAME PASSWORD   - login to rapidshare"
            echo "-d link                - download file"
        ;;
    esac
}

helps ()
{
    echo "mu       - do operation on megaupload"
    echo "rs       - do operation on rapidshare"
    echo "-h       - show this helps"
    echo "<file>   - dowload links from file"
    exit
}

case $1 in
    "mu")
        shift
        megaupload "$@"
    ;;
    "rs")
        shift
        rapidshare "$@"
    ;;
    "-h"|"--help")
        helps
    ;;
    *)
        if [[ $# != 1 ]]; then
            helps
        fi

        if [[ ! -e "$1" ]]; then
            echo "File doesn't exists"
            exit
        fi

        for i in `cat "$1" | grep 'http://rapidshare\.com/files/'`; do
            rapidshare -d "$i"
        done

        for i in `cat "$1" | grep -E 'http://(www\.|)megaupload\.com/'`; do
            megaupload -d "$i"
        done
    ;;
esac
