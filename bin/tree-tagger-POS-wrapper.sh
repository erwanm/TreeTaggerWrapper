#!/bin/bash

source file-lib.sh
source common-lib.sh


progName=$(basename "$BASH_SOURCE")
pathTreeTagger="$TREE_TAGGER_PATH"
lggeIds="english spanish dutch french german russian italian"
debug=0



function usage {
  echo
  echo "Usage: $progName [options] <lgge id>"
  echo 
  echo "  Reads TOKENIZED input from STDIN, and writes the 3-columns output to STDOUT."
  echo "  The output from tree-tagger-tokenizer-wrapper.sh can be piped as input."
  echo "  Valid language ids are: '$lggeIds'."
  echo
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
    paramFile="$pathTreeTagger/lib/${lang}-utf8.par"
    if [ ! -f "$paramFile" ]; then
	paramFile="$pathTreeTagger/lib/${lang}.par"
	if [ ! -f "$paramFile" ]; then
	    echo "$progName: Error, cannot find TreeTagger parameter file ${lang}-utf8.par or ${lang}.par in $pathTreeTagger/lib" 1>&2
	    exit 4
	fi
    fi
    tmpErr=$(mktemp "$progName.XXXXXXXX.err")
    cmd="$pathTreeTagger/bin/tree-tagger -token -lemma \"$paramFile\"  2>\"$tmpErr\""
    if [ $lang == "english" ]; then # for some reason, english and german require some postprocessing (see scripts cmd/tree-tagger-<lang>)
	cmd="$cmd | perl -pe 's/\tV[BDHV]/\tVB/;s/\tIN\/that/\tIN/;'"
    elif [ $lang == "german" ]; then
	cmd="$cmd | $pathTreeTagger/cmd/filter-german-tags"
    fi
    if [ $debug -ne 0 ]; then
	echo "$progName: command is '$cmd'" 1>&2
    fi
    evalSafe "$cmd" "$progName,$LINENO: "
    if [ $(cat $tmpErr | wc -l) -ne 3 ]; then
	echo "$progName: an error occured, STDERR is:" 1>&2
	cat "$tmpErr" 1>&2
	rm -f "$tmpErr"
	exit 5
    fi
    rm -f "$tmpErr"
else
    echo "$progName: Error, language '$lang' not recognized" 1>&2
    exit 4
fi



