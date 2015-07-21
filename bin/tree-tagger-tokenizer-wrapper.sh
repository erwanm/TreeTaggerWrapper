#!/bin/bash

source file-lib.sh
source common-lib.sh

progName=$(basename "$BASH_SOURCE")
pathTreeTagger=$TREE_TAGGER_PATH
lggeIds="english spanish dutch french german russian italian"
debug=0

function usage {
  echo
  echo "Usage: $progName [options] <lgge id>"
  echo
  echo "  Reads input text from STDIN and writes tokenized text (one"
  echo "  token by line) to STDOUT."
  echo
  echo "  Available language ids: '$lggesIds'"
  echo "   Options:"
  echo "     -d debug mode: print the command to STDERR"
  echo "     -t <path to TreeTagger> default: $pathTreeTagger"
  echo
}


while getopts 'ht:d' option ; do 
    case $option in
	"d" ) debug=1;;
	"t" ) pathTreeTagger="$OPTARG";;
	"h" ) usage
 	      exit 0;;
	"?" ) 
	    echo "Error, unknow option." 1>&2
            printHelp=1;;
    esac
done
shift $(($OPTIND - 1))
if [ $# -ne 1 ]; then
    echo "Error: 1 args expected" 1>&2
    printHelp=1
fi
lang="$1"
if [ ! -z "$printHelp" ]; then
    usage 1>&2
    exit 1
fi

dieIfNoSuchDir "$pathTreeTagger" "$progName,$LINENO: "
memberList $lang "$lggeIds"
if memberList $lang "$lggeIds"; then
    tokOptions=""
    if [ "$lang" == "english" ]; then
	tokOptions="$tokOptions -e"
    elif [ "$lang" == "french" ]; then
	tokOptions="$tokOptions -f"
    elif [ "$lang" == "italian" ]; then
	tokOptions="$tokOptions -i"
    fi
    abbrevFile="$pathTreeTagger/lib/${lang}-abbreviations-utf8"
    if [ ! -f "$abbrevFile" ]; then
	abbrevFile="$pathTreeTagger/lib/${lang}-abbreviations"
    fi
    if [ -f "$abbrevFile" ]; then # still possible that there is no file at all
	tokOptions="$tokOptions -a \"$abbrevFile\""
    else
	echo "$progName: Warning: no abbreviation file found for language '$lang'" 1>&2
    fi
    cmd="$pathTreeTagger/cmd/utf8-tokenize.perl $tokOptions | grep -v \"^$\" "
    if [ $debug -ne 0 ]; then
	echo "$progName: command is '$cmd'" 1>&2
    fi
    evalSafe "$cmd" "$progName,$LINENO: "
else
    echo "$progName: Error, language '$lang' not recognized" 1>&2
    exit 4
fi


