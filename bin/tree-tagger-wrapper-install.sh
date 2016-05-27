#!/bin/bash

# EM April 14

source common-lib.sh
source file-lib.sh

progName=$(basename "$BASH_SOURCE")
languages="english dutch spanish french german italian russian"
chunkers=
oldVersion=

function usage {
  echo
  echo "Usage: $progName [options] <target dir>"
  echo
  echo "  TODO"
  echo
  echo "  Options:"
  echo "    -l <list of languages (space separated)> default: '$languages'"
  echo "    -o use old version (in case TreeTagger gives the error message:"
  echo "       'FATAL: kernel too old')"
  echo "    -h this help"
  echo
}



OPTIND=1
while getopts 'ho' option ; do 
    case $option in
	"h" ) usage
 	      exit 0;;
	"o" ) oldVersion=1;;
	"?" ) 
	    echo "Error, unknow option." 1>&2
            printHelp=1;;
    esac
done
shift $(($OPTIND - 1))
if [ $# -ne 1 ]; then
    echo "Error: expecting 1 args." 1>&2
    printHelp=1
fi
if [ ! -z "$printHelp" ]; then
    usage 1>&2
    exit 1
fi

dir="$1"
mkdirSafe "$1" "$progName,$LINENO: "
pushd "$dir" >/dev/null
if [ -z "$oldVersion" ]; then
    evalSafe "wget http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/tree-tagger-linux-3.2.tar.gz" "$progName,$LINENO: "
else
    evalSafe "wget http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/tree-tagger-linux-3.2-old.tar.gz"  "$progName,$LINENO: "
fi
evalSafe "wget http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/tagger-scripts.tar.gz" "$progName,$LINENO: "
evalSafe "wget http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/install-tagger.sh" "$progName,$LINENO: "
for lang in $languages; do
    evalSafe "wget http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/${lang}-par-linux-3.2-utf8.bin.gz" "$progName,$LINENO: "
done
evalSafe "bash install-tagger.sh" "$progName,$LINENO: "

popd >/dev/null
