#!/bin/bash
LANGS=('abap' 'actionscript' 'actionscript3' 'ada' 'apache' 'applescript' 'asm' 'asp' 'autoit' 
       'avisynth' 'bash' 'basic4gl' 'bibtex' 'blitzbasic' 'bnf' 'boo' 'bf' 'c' 'cill' 'csharp'
       'cpp' 'caddcl' 'cadlisp' 'cfdg' 'klonec' 'klonecpp' 'cmake' 'cobol' 'cfm' 'css' 'd'
       'dcs' 'delphi' 'dff' 'div' 'dos' 'dot' 'eiffel' 'email' 'erlang' 'fo' 'fortran'
       'freebasic' 'gml' 'genero' 'gettext' 'groovy' 'haskell' 'hq9plus' 'html4strict' 'idl'
       'ini' 'inno' 'intercal' 'io' 'java' 'java5' 'javascript' 'kixtart' 'latex' 'lsl2' 'lisp'
       'locobasic' 'lolcode' 'lotusformulas' 'lotusscript' 'lscript' 'lua' 'm68k' 'make' 'matlab'
       'matlab' 'mirc' 'modula3' 'mpasm' 'mxml' 'mysql' 'text' 'nsis' 'oberon2' 'objc' 'ocaml'
       'glsl' 'oobas' 'oracle11' 'oracle8' 'pascal' 'pawn' 'per' 'perl' 'php' 'pic16'
       'pixelbender' 'plsql' 'povray' 'powershell' 'progress' 'prolog' 'properties' 'providex'
       'python' 'qbasic' 'rails' 'rebol' 'reg' 'robots' 'ruby' 'gnuplot' 'sas' 'scala' 'scheme'
       'scilab' 'sdlbasic' 'smalltalk' 'smarty' 'sql' 'tsql' 'tcl' 'tcl' 'teraterm' 'thinbasic'
       'typoscript' 'unreal' 'vbnet' 'verilog' 'vhdl' 'vim' 'visualprolog' 'vb' 'visualfoxpro'
       'whitespace' 'whois' 'winbatch' 'xml' 'xpp' 'z80')
LANGUAGES=('ABAP' 'ActionScript' 'ActionScript 3' 'Ada' 'Apache Log' 'AppleScript' 'ASM (NASM)'
           'ASP' 'AutoIt' 'Avisynth' 'Bash' 'Basic4GL' 'BibTeX' 'Blitz Basic' 'BNF' 'BOO'
           'BrainFuck' 'C' 'C Intermediate Language' 'C#' 'C++' 'CAD DCL' 'CAD Lisp' 'CFDG'
           'Clone C' 'Clone C++' 'CMake' 'COBOL' 'ColdFusion' 'CSS' 'D' 'DCS' 'Delphi' 'Diff'
           'DIV' 'DOS' 'DOT' 'Eiffel' 'Email' 'Erlang' 'FO Language' 'Fortran' 'FreeBasic'
           'Game Maker' 'Genero' 'GetText' 'Groovy' 'Haskell' 'HQ9 Plus' 'HTML' 'IDL' 'INI file'
           'Inno Script' 'INTERCAL' 'IO' 'Java' 'Java 5' 'JavaScript' 'KiXtart' 'Latex'
           'Linden Scripting' 'Lisp' 'Loco Basic' 'LOL Code' 'Lotus Formulas' 'Lotus Script'
           'LScript' 'Lua' 'M68000 Assembler' 'Make' 'MatLab' 'MatLab' 'mIRC' 'Modula 3' 'MPASM'
           'MXML' 'MySQL' 'None' 'NullSoft Installer' 'Oberon 2' 'Objective C' 'OCaml'
           'OpenGL Shading' 'Openoffice BASIC' 'Oracle 11' 'Oracle 8' 'Pascal' 'PAWN' 'Per' 'Perl'
           'PHP' 'Pic 16' 'Pixel Bender' 'PL/SQL' 'POV-Ray' 'Power Shell' 'Progress' 'Prolog'
           'Properties' 'ProvideX' 'Python' 'QBasic' 'Rails' 'REBOL' 'REG' 'Robots' 'Ruby'
           'Ruby Gnuplot' 'SAS' 'Scala' 'Scheme' 'Scilab' 'SdlBasic' 'Smalltalk' 'Smarty' 'SQL'
           'T-SQL' 'TCL' 'TCL' 'Tera Term' 'thinBasic' 'TypoScript' 'unrealScript' 'VB.NET'
           'VeriLog' 'VHDL' 'VIM' 'Visual Pro Log' 'VisualBasic' 'VisualFoxPro' 'WhiteSpace'
           'WHOIS' 'Win Batch' 'XML' 'XPP' 'Z80 Assembler')
EXPIRE_TIMES=('N' '10M' '1H' '1D' '1M')

LANG=""
PRIVATE="0"
EMAIL=""
EXPIRE=""
NAME=""
PASTE="curl -s -H Expect: -F 'paste_code=<-' "

helps ()
{
    echo "USAGE:"
    echo -e "\t${0} -h"
    echo -e "\t${0} -L"
    echo -e "\t${0} [-p] [-l <language>] [-e <expire>] [-n <name>]\\"
    echo -e "\t\t[-E <email>] file"
    echo
    echo "-p                 Make it private"
    echo "-l <language>      Set the highlighting syntax"
    echo "-e <expire>        N = Never, 10M = 10 Minutes, 1H = 1 Hour, 1D = 1 Day, 1M = 1 Month"
    echo "-n <name>          Add a title to your paste"
    echo "-E <email>         Send confirmation email with paste link"
    exit
}

showlangs ()
{
    for ((i=0; $i < ${#LANGS[@]}; i++)); do
        echo -e "${LANGS[$i]}\t\t${LANGUAGES[$i]}"
    done
    exit
}

lang_exists ()
{
    for ((i=0; $i < ${#LANGS[@]}; i++)); do
        if [[ "${LANGS[$i]}" = "${1}" ]]; then
            echo "1"
            return
        fi
    done
}

right_expire ()
{
    for ((i=0; $i < ${#EXPIRE_TIMES[@]}; i++)); do
        if [[ "${EXPIRE_TIMES[$i]}" = "${1}" ]]; then
            echo "1"
            return
        fi
    done
}

while getopts "hLpl:e:n:s:E:" flag; do
    case "${flag}" in
        "h")
            helps
        ;;
        "L")
            showlangs
        ;;
        "p")
            PRIVATE="1"
        ;;
        "l")
            if [[ -z "$(lang_exists $OPTARG)" ]]; then
                echo "Language doesn't exist" >&2
                exit
            fi
            LANG="${OPTARG}"
        ;;
        "e")
            if [[ -z "$(right_expire $OPTARG)" ]]; then
                echo "Expire time is NOT right" >&2
                exit
            fi
            EXPIRE="${OPTARG}"
        ;;
        "n")
            NAME="${OPTARG}"
        ;;
        "E")
            EMAIL="${OPTARG}"
        ;;
        "?")
            exit
        ;;
    esac
    shift $((OPTIND - 1))
done

if [[ "$#" != "1" ]]; then
    echo "An error as occured, see help" >&2
    exit
fi

if [[ ! -e "${1}" ]]; then
    echo "File doesn't exist" >&2
    exit
fi

if [[ ! -z "${NAME}" ]]; then
    PASTE+="-F 'paste_name=${NAME}' "
fi

if [[ ! -z "${EMAIL}" ]]; then
    PASTE+="-F 'paste_email=${EMAIL}' "
fi

if [[ "${PRIVATE}" = "1" ]]; then
    PASTE+="-F 'paste_private=1' "
fi

if [[ ! -z "${EXPIRE}" ]]; then
    PASTE+="-F 'paste_expire_date=${EXPIRE}' "
fi

if [[ ! -z "${LANG}" ]]; then
    PASTE+="-F 'paste_format=${LANG}' "
fi

PASTE+='http://pastebin.com/api_public.php'


eval "cat '${1}' | $PASTE"
echo
