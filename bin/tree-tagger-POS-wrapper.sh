#!/bin/bash



progName=$(basename "$BASH_SOURCE")
pathTreeTagger="$TREE_TAGGER_PATH"
lggeIds="english spanish dutch french german russian italian"

function usage {
  echo
  echo "Usage: $progName [options] <lgge id> <tokenized input filename> <output filename>"
  echo 
  echo "  Valid language ids are: $lggeIds"
  echo
  echo "   Options:"
  echo "     -t <path to TreeTagger> default: $pathTreeTagger"
  echo
}


while getopts 'ha:t:' option ; do 
    case $option in
	"a" ) pathAUEB="$OPTARG";;
	"t" ) pathTreeTagger="$OPTARG";;
	"h" ) usage
 	      exit 0;;
	"?" ) 
	    echo "Error, unknow option." 1>&2
            printHelp=1;;
    esac
done
shift $(($OPTIND - 1))
if [ $# -ne 3 ]; then
    echo "Error: 3 args expected" 1>&2
    printHelp=1
fi
lang="$1"
input="$2"
output="$3"
if [ ! -z "$printHelp" ]; then
    usage 1>&2
    exit 1
fi

if [ ! -f "$input" ]; then
    echo "can not find input file '$input'" 1>&2
    exit 2
fi

if [ "$lang" == "GR" ] || [ "$lang" == "greek" ] || [ "$lang" == "Greek" ]; then
    echo "$progName: error Greek not supported anymore" 1>&2
    exit 1
#    AUEB-POSTagger-wrapper.sh "$pathAUEB" $optFineGrainedGR "$input" > "$output"
elif  [ "$lang" == "SP" ] || [ "$lang" == "es" ] || [ "$lang" == "spanish" ] || [ "$lang" == "Spanish" ]; then
    tmpErr=$(mktemp --tmpdir)
    cat "$input" | $pathTreeTagger/bin/tree-tagger -token $pathTreeTagger/lib/spanish-utf8.par > "$output" 2>$tmpErr
    if [ $(cat $tmpErr | wc -l) -ne 3 ]; then
	echo "$progName: Something went wrong, check $tmpErr" 1>&2
	exit 5
    fi
    rm -f $tmpErr
elif  [ "$lang" == "FR" ] || [ "$lang" == "fr" ] || [ "$lang" == "french" ] || [ "$lang" == "French" ]; then
    tmpErr=$(mktemp --tmpdir)
    cat "$input" | $pathTreeTagger/bin/tree-tagger -token $pathTreeTagger/lib/french-utf8.par > "$output" 2>$tmpErr
    if [ $(cat $tmpErr | wc -l) -ne 3 ]; then
	echo "$progName: Something went wrong, check $tmpErr" 1>&2
	exit 5
    fi
    rm -f $tmpErr
elif  [ "$lang" == "DU" ] || [ "$lang" == "du" ] || [ "$lang" == "dutch" ] || [ "$lang" == "Dutch" ]; then
    tmpErr=$(mktemp --tmpdir)
    cat "$input" | $pathTreeTagger/bin/tree-tagger -token $pathTreeTagger/lib/dutch-utf8.par > "$output" 2>$tmpErr
    if [ $(cat $tmpErr | wc -l) -ne 3 ]; then
	echo "$progName: Something went wrong, check $tmpErr" 1>&2
	exit 5
    fi
    rm -f $tmpErr
else
    if [ "$lang" != "EN" ] && [ "$lang" != "en" ] && [ "$lang" != "english" ] && [ "$lang" != "English" ]; then
	echo "$progName: Warning: unknown language id $lang. English parsing will be performed." 1>&2
    fi
    engTTParFile="$pathTreeTagger/lib/english-utf8.par"
    if [ ! -f "$engTTParFile" ]; then
	if [ -f "$pathTreeTagger/lib/english.par" ]; then
	    engTTParFile="$pathTreeTagger/lib/english.par"
	else
	    echo "$progName: error, no TreeTagger .par file  '$engTTParFile' or '$pathTreeTagger/lib/english.par'" 1>&2
	    exit 45
	fi
    fi
    tmpErr=$(mktemp --tmpdir)
    cat "$input" | $pathTreeTagger/bin/tree-tagger -token $engTTParFile   2>$tmpErr | perl -pe 's/\tV[BDHV]/\tVB/;s/\tIN\/that/\tIN/;'  > "$output"
    if [ $(cat $tmpErr | wc -l) -ne 3 ]; then
	echo "$progName: Something went wrong, check $tmpErr" 1>&2
	exit 5
    fi
    rm -f $tmpErr
fi

